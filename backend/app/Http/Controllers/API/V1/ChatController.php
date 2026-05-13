<?php

namespace App\Http\Controllers\API\V1;

use App\Events\MessageSent;
use App\Http\Controllers\Controller;
use App\Models\Chat;
use App\Models\Message;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChatController extends Controller
{
    public function conversations(Request $request): JsonResponse
    {
        $me = $request->user();

        $chats = $me->chats()
            ->with(['participants', 'lastMessage'])
            ->latest('updated_at')
            ->get();

        $data = $chats->map(function ($chat) use ($me) {
            $other = $chat->participants->firstWhere('id', '!=', $me->id);
            $unread = $chat->messages()
                ->where('sender_id', '!=', $me->id)
                ->whereNull('read_at')
                ->count();

            return [
                'id'           => $chat->id,
                'participant'  => $other ? ['id' => $other->id, 'name' => $other->name] : null,
                'last_message' => $chat->lastMessage ? ['body' => $chat->lastMessage->body] : null,
                'unread_count' => $unread,
                'updated_at'   => $chat->updated_at,
            ];
        });

        return response()->json(['success' => true, 'data' => $data]);
    }

    public function findOrCreate(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'recipient_id' => 'required|exists:users,id',
        ]);

        $me = $request->user();
        $recipientId = $validated['recipient_id'];

        $chat = $me->chats()
            ->whereIn('chats.id', function ($q) use ($recipientId) {
                $q->select('chat_id')
                  ->from('chat_user')
                  ->where('user_id', $recipientId);
            })
            ->first();

        if (! $chat) {
            $chat = Chat::create();
            $chat->participants()->attach([$me->id, $recipientId]);
        }

        return response()->json(['success' => true, 'data' => ['id' => $chat->id]]);
    }

    public function messages(Request $request, Chat $chat): JsonResponse
    {
        abort_unless($chat->participants()->where('user_id', $request->user()->id)->exists(), 403);

        $query = $chat->messages()->orderBy('id', 'asc');

        if ($request->filled('after_id')) {
            $query->where('id', '>', $request->integer('after_id'));
        }

        $messages = $query->get()->map(fn($m) => [
            'id'             => $m->id,
            'body'           => $m->body,
            'attachment_url' => $m->attachment_url,
            'sender_id'      => $m->sender_id,
            'created_at'     => $m->created_at,
        ]);

        // Mark incoming messages as read
        $chat->messages()
            ->where('sender_id', '!=', $request->user()->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json(['success' => true, 'data' => $messages]);
    }

    public function send(Request $request, Chat $chat): JsonResponse
    {
        abort_unless($chat->participants()->where('user_id', $request->user()->id)->exists(), 403);

        $validated = $request->validate([
            'body'  => 'nullable|string|max:5000',
            'image' => 'nullable|image|max:5120',
        ]);

        if (empty($validated['body']) && !$request->hasFile('image')) {
            return response()->json(['success' => false, 'message' => 'Message or image required'], 422);
        }

        $attachmentUrl = null;
        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('chat-images', 'public');
            $attachmentUrl = url('storage/' . $path);
        }

        $message = Message::create([
            'chat_id'        => $chat->id,
            'sender_id'      => $request->user()->id,
            'body'           => $validated['body'] ?? '',
            'attachment_url' => $attachmentUrl,
        ]);

        $chat->touch();

        try {
            broadcast(new MessageSent($message));
        } catch (\Throwable) {
            // Reverb not running — message saved, real-time delivery skipped
        }

        return response()->json([
            'success' => true,
            'data'    => [
                'id'             => $message->id,
                'body'           => $message->body,
                'attachment_url' => $message->attachment_url,
                'sender_id'      => $message->sender_id,
                'created_at'     => $message->created_at,
            ],
        ], 201);
    }
}
