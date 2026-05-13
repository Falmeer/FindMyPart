<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class SparePart extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id', 'category_id', 'name', 'condition', 'price',
        'quantity', 'description', 'compatibility', 'has_warranty', 'is_active',
    ];

    protected $casts = [
        'price' => 'float',
        'has_warranty' => 'boolean',
        'is_active' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function images()
    {
        return $this->hasMany(SparePartImage::class);
    }

    public function favorites()
    {
        return $this->morphMany(Favorite::class, 'favoritable');
    }

    public function scopeFilter($query, array $filters)
    {
        return $query
            ->when($filters['category'] ?? null, fn($q, $v) => $q->whereHas('category', fn($c) => $c->where('slug', $v)))
            ->when($filters['condition'] ?? null, fn($q, $v) => $q->where('condition', $v))
            ->when($filters['min_price'] ?? null, fn($q, $v) => $q->where('price', '>=', $v))
            ->when($filters['max_price'] ?? null, fn($q, $v) => $q->where('price', '<=', $v))
            ->when($filters['search'] ?? null, fn($q, $v) => $q->where('name', 'like', "%{$v}%"));
    }
}
