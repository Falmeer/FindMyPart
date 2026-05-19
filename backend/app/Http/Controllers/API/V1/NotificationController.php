<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $notifications = $request->user()
            ->notifications()
            ->latest()
            ->paginate(30);

        $data = $notifications->map(fn($n) => [
            'id'         => $n->id,
            'type'       => $n->data['type'] ?? 'unknown',
            'title'      => $n->data['title'] ?? '',
            'body'       => $n->data['body'] ?? '',
            'data'       => $n->data,
            'read_at'    => $n->read_at?->toISOString(),
            'created_at' => $n->created_at->toISOString(),
        ]);

        return response()->json([
            'success'      => true,
            'data'         => $data,
            'unread_count' => $request->user()->unreadNotifications()->count(),
        ]);
    }

    public function unreadCount(Request $request): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data'    => ['count' => $request->user()->unreadNotifications()->count()],
        ]);
    }

    public function markRead(Request $request, string $id): JsonResponse
    {
        $notification = $request->user()->notifications()->findOrFail($id);
        $notification->markAsRead();

        return response()->json(['success' => true]);
    }

    public function markAllRead(Request $request): JsonResponse
    {
        $request->user()->unreadNotifications->markAsRead();

        return response()->json(['success' => true]);
    }
}
