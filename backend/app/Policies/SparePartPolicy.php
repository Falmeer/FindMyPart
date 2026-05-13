<?php

namespace App\Policies;

use App\Models\SparePart;
use App\Models\User;

class SparePartPolicy
{
    public function update(User $user, SparePart $sparePart): bool
    {
        return $user->id === $sparePart->user_id;
    }

    public function delete(User $user, SparePart $sparePart): bool
    {
        return $user->id === $sparePart->user_id;
    }
}
