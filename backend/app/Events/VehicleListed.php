<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class VehicleListed implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(public int $vehicleId) {}

    public function broadcastOn(): array
    {
        return [new Channel('vehicles')];
    }

    public function broadcastWith(): array
    {
        return ['id' => $this->vehicleId];
    }

    public function broadcastAs(): string
    {
        return 'VehicleListed';
    }
}
