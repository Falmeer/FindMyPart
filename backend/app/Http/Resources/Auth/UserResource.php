<?php

namespace App\Http\Resources\Auth;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'               => $this->id,
            'name'             => $this->name,
            'email'            => $this->email,
            'phone'            => $this->phone,
            'phone_verified'        => ! is_null($this->phone_verified_at),
            'must_change_password'  => (bool) $this->must_change_password,
            'role'                  => $this->role,
            'avatar'           => $this->avatar,
            'is_active'        => $this->is_active,
            'created_at'       => $this->created_at->toISOString(),
        ];
    }
}
