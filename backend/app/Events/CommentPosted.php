<?php

namespace App\Events;

use App\Models\IssueComment;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class CommentPosted implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(public IssueComment $comment) {}

    public function broadcastOn(): array
    {
        return [new Channel('issues.' . $this->comment->vehicle_issue_id)];
    }

    public function broadcastWith(): array
    {
        return [
            'id'         => $this->comment->id,
            'user_id'    => $this->comment->user_id,
            'user_name'  => $this->comment->user->name ?? 'Anonymous',
            'body'       => $this->comment->body,
            'created_at' => $this->comment->created_at->toISOString(),
        ];
    }

    public function broadcastAs(): string
    {
        return 'CommentPosted';
    }
}
