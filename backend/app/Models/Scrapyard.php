<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Scrapyard extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id', 'name', 'description', 'phone', 'address',
        'latitude', 'longitude', 'services', 'working_hours',
        'rating', 'review_count', 'is_verified', 'is_active',
    ];

    protected $casts = [
        'services'    => 'array',
        'latitude'    => 'float',
        'longitude'   => 'float',
        'rating'      => 'float',
        'is_verified' => 'boolean',
        'is_active'   => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function favorites()
    {
        return $this->morphMany(Favorite::class, 'favoritable');
    }

    public function reviews()
    {
        return $this->hasMany(ScrapyardReview::class);
    }

    public function scopeNearby($query, float $lat, float $lng, float $radiusKm = 10)
    {
        return $query->selectRaw(
            '*, (6371 * acos(cos(radians(?)) * cos(radians(latitude)) *
            cos(radians(longitude) - radians(?)) + sin(radians(?)) *
            sin(radians(latitude)))) AS distance_km',
            [$lat, $lng, $lat]
        )->having('distance_km', '<=', $radiusKm)->orderBy('distance_km');
    }
}
