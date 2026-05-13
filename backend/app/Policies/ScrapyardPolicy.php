<?php

namespace App\Policies;

use App\Models\Scrapyard;
use App\Models\User;

class ScrapyardPolicy
{
    public function create(User $user): bool
    {
        return $user->isYardOwner();
    }
}
