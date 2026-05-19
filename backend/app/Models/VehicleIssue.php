<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class VehicleIssue extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id', 'brand', 'model', 'year', 'description', 'status', 'latitude', 'longitude',
    ];

    protected $casts = [
        'latitude' => 'float',
        'longitude' => 'float',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function offers()
    {
        return $this->hasMany(GarageOffer::class);
    }

    public function comments()
    {
        return $this->hasMany(IssueComment::class)->latest();
    }
}
