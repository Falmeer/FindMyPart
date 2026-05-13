<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SparePartImage extends Model
{
    protected $fillable = ['spare_part_id', 'path', 'url', 'is_primary'];

    protected $casts = ['is_primary' => 'boolean'];

    public function sparePart()
    {
        return $this->belongsTo(SparePart::class);
    }
}
