<?php

namespace App\Http\Resources\SparePart;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SparePartResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'condition' => $this->condition,
            'price' => (float) $this->price,
            'quantity' => (int) $this->quantity,
            'description' => $this->description,
            'compatibility' => $this->compatibility,
            'has_warranty' => (bool) $this->has_warranty,
            'category' => $this->category ? [
                'id' => $this->category->id,
                'name' => $this->category->name,
                'slug' => $this->category->slug,
            ] : null,
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
