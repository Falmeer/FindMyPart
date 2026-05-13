<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class GarageOffer extends Model
{
    protected $fillable = ['vehicle_issue_id', 'garage_id', 'message', 'price', 'status'];

    protected $casts = ['price' => 'float'];

    public function issue()
    {
        return $this->belongsTo(VehicleIssue::class, 'vehicle_issue_id');
    }

    public function garage()
    {
        return $this->belongsTo(Garage::class);
    }
}
