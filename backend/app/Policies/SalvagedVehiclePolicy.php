<?php

namespace App\Policies;

use App\Models\SalvagedVehicle;
use App\Models\User;

class SalvagedVehiclePolicy
{
    public function create(User $user): bool
    {
        return $user->isYardOwner();
    }

    public function update(User $user, SalvagedVehicle $vehicle): bool
    {
        return $user->id === $vehicle->user_id;
    }

    public function delete(User $user, SalvagedVehicle $vehicle): bool
    {
        return $user->id === $vehicle->user_id;
    }
}
