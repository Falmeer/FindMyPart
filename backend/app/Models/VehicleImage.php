<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class VehicleImage extends Model
{
    protected $fillable = ['salvaged_vehicle_id', 'path', 'url', 'is_primary'];

    protected $casts = ['is_primary' => 'boolean'];

    public function vehicle()
    {
        return $this->belongsTo(SalvagedVehicle::class, 'salvaged_vehicle_id');
    }
}
