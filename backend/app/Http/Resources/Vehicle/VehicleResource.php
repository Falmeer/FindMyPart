<?php

namespace App\Http\Resources\Vehicle;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class VehicleResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'brand' => $this->brand,
            'model' => $this->model,
            'year' => (int) $this->year,
            'engine' => $this->engine,
            'transmission' => $this->transmission,
            'mileage' => $this->mileage !== null ? (int) $this->mileage : null,
            'condition' => $this->condition,
            'vin' => $this->vin,
            'description' => $this->description,
            'price' => $this->price,
            'is_available' => $this->is_available,
            'images' => $this->images->map(fn($img) => [
                'id' => $img->id,
                'url' => $img->url,
                'is_primary' => $img->is_primary,
            ]),
            'seller' => [
                'id' => $this->user->id,
                'name' => $this->user->name,
                'phone' => $this->user->phone,
                'avatar' => $this->user->avatar,
            ],
            'user_id' => $this->user_id,
            'is_favorited' => ($u = auth('sanctum')->user())
                ? $this->favorites()->where('user_id', $u->id)->exists()
                : false,
            'created_at' => $this->created_at->toISOString(),
        ];
    }
}
