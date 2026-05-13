<?php

namespace App\Http\Resources\Garage;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class GarageResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'name' => $this->name,
            'description' => $this->description,
            'phone' => $this->phone,
            'address' => $this->address,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'services' => $this->services ?? [],
            'working_hours' => $this->working_hours,
            'rating' => round($this->rating, 1),
            'review_count' => $this->review_count,
            'is_verified' => $this->is_verified,
            'distance_km' => $this->when(isset($this->distance_km), $this->distance_km),
            'images' => $this->whenLoaded('images', fn() => $this->images->map(fn($img) => [
                'id' => $img->id,
                'url' => $img->url,
            ])),
            'reviews' => $this->whenLoaded('reviews', fn() => $this->reviews->map(fn($r) => [
                'id' => $r->id,
                'rating' => $r->rating,
                'comment' => $r->comment,
                'user' => ['name' => $r->user->name, 'avatar' => $r->user->avatar],
                'created_at' => $r->created_at->toISOString(),
            ])),
            'is_favorited' => ($u = auth('sanctum')->user())
                ? $this->favorites()->where('user_id', $u->id)->exists()
                : false,
            'created_at' => $this->created_at->toISOString(),
        ];
    }
}
