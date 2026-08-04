<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DeviceRegistration extends Model
{
    protected $fillable = [
        'device_id',
        'phone',
        'fcm_token',
        'platform',
        'is_active',
        'last_seen_at',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'last_seen_at' => 'datetime',
        ];
    }
}
