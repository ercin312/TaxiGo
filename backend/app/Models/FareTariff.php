<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FareTariff extends Model
{
    protected $fillable = [
        'name',
        'vehicle_type',
        'base_fare',
        'per_km_rate',
        'per_minute_rate',
        'minimum_fare',
        'surge_multiplier',
        'currency',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'base_fare' => 'decimal:2',
            'per_km_rate' => 'decimal:2',
            'per_minute_rate' => 'decimal:2',
            'minimum_fare' => 'decimal:2',
            'surge_multiplier' => 'decimal:2',
            'is_active' => 'boolean',
        ];
    }
}
