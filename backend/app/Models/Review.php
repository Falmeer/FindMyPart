<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    protected $fillable = ['user_id', 'garage_id', 'rating', 'comment'];

    protected static function booted(): void
    {
        static::saved(fn(Review $review) => $review->updateGarageRating());
        static::deleted(fn(Review $review) => $review->updateGarageRating());
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function garage()
    {
        return $this->belongsTo(Garage::class);
    }

    private function updateGarageRating(): void
    {
        $garage = $this->garage;
        $garage->update([
            'rating' => $garage->reviews()->avg('rating') ?? 0,
            'review_count' => $garage->reviews()->count(),
        ]);
    }
}
