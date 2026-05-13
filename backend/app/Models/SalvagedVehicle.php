<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class SalvagedVehicle extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id', 'brand', 'model', 'year', 'engine', 'transmission',
        'mileage', 'condition', 'vin', 'description', 'price',
        'is_available', 'is_active',
    ];

    protected $casts = [
        'price' => 'float',
        'is_available' => 'boolean',
        'is_active' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function images()
    {
        return $this->hasMany(VehicleImage::class);
    }

    public function favorites()
    {
        return $this->morphMany(Favorite::class, 'favoritable');
    }

    public function scopeSearch($query, string $term)
    {
        return $query->where(function ($q) use ($term) {
            $q->where('brand', 'like', "%{$term}%")
              ->orWhere('model', 'like', "%{$term}%")
              ->orWhere('description', 'like', "%{$term}%");
        });
    }

    public function scopeFilter($query, array $filters)
    {
        return $query
            ->when($filters['brand'] ?? null, fn($q, $v) => $q->where('brand', $v))
            ->when($filters['model'] ?? null, fn($q, $v) => $q->where('model', $v))
            ->when($filters['year_from'] ?? null, fn($q, $v) => $q->where('year', '>=', $v))
            ->when($filters['year_to'] ?? null, fn($q, $v) => $q->where('year', '<=', $v))
            ->when($filters['condition'] ?? null, fn($q, $v) => $q->where('condition', $v))
            ->when($filters['search'] ?? null, fn($q, $v) => $q->search($v));
    }
}
