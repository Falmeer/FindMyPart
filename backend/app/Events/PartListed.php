<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class PartListed implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(public int $partId) {}

    public function broadcastOn(): array
    {
        return [new Channel('parts')];
    }

    public function broadcastWith(): array
    {
        return ['id' => $this->partId];
    }

    public function broadcastAs(): string
    {
        return 'PartListed';
    }
}
