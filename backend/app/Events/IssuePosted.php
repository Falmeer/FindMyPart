<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class IssuePosted implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(public int $issueId) {}

    public function broadcastOn(): array
    {
        return [new Channel('issues')];
    }

    public function broadcastWith(): array
    {
        return ['id' => $this->issueId];
    }

    public function broadcastAs(): string
    {
        return 'IssuePosted';
    }
}
