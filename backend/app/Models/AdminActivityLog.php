<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AdminActivityLog extends Model
{
    protected $fillable = [
        'admin_id', 'action', 'target_type', 'target_id',
        'description', 'metadata', 'ip_address',
    ];

    protected $casts = [
        'metadata' => 'array',
    ];

    public function admin()
    {
        return $this->belongsTo(User::class, 'admin_id');
    }

    public static function record(string $action, string $description, ?string $targetType = null, ?int $targetId = null, array $metadata = []): void
    {
        static::create([
            'admin_id'    => auth()->id(),
            'action'      => $action,
            'target_type' => $targetType,
            'target_id'   => $targetId,
            'description' => $description,
            'metadata'    => $metadata ?: null,
            'ip_address'  => request()->ip(),
        ]);
    }
}
