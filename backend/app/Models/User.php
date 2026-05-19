<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    protected $fillable = [
        'name', 'email', 'phone', 'phone_verified_at', 'password', 'avatar', 'role',
        'is_active', 'must_change_password', 'fcm_token', 'is_banned', 'banned_reason', 'banned_at',
    ];

    protected $hidden = ['password', 'remember_token'];

    protected $casts = [
        'email_verified_at'  => 'datetime',
        'phone_verified_at'  => 'datetime',
        'banned_at'          => 'datetime',
        'password'           => 'hashed',
        'is_active'            => 'boolean',
        'must_change_password' => 'boolean',
        'is_banned'            => 'boolean',
    ];

    public function garage()
    {
        return $this->hasOne(Garage::class);
    }

    public function scrapyard()
    {
        return $this->hasOne(Scrapyard::class);
    }

    public function salvagedVehicles()
    {
        return $this->hasMany(SalvagedVehicle::class);
    }

    public function spareParts()
    {
        return $this->hasMany(SparePart::class);
    }

    public function vehicleIssues()
    {
        return $this->hasMany(VehicleIssue::class);
    }

    public function favorites()
    {
        return $this->hasMany(Favorite::class);
    }

    public function chats()
    {
        return $this->belongsToMany(Chat::class)->withPivot('last_read_at');
    }

    public function sentMessages()
    {
        return $this->hasMany(Message::class, 'sender_id');
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function isCustomer(): bool { return $this->role === 'customer'; }
    public function isGarage(): bool { return $this->role === 'garage'; }
    public function isYardOwner(): bool { return $this->role === 'yard_owner'; }
    public function isAdmin(): bool { return $this->role === 'admin'; }
}
