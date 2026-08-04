<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RideLocation extends Model
{
    protected $fillable = [
        'ride_id',
        'latitude',
        'longitude',
        'heading',
        'speed',
        'recorded_at',
    ];

    protected function casts(): array
    {
        return [
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
            'heading' => 'decimal:2',
            'speed' => 'decimal:2',
            'recorded_at' => 'datetime',
        ];
    }

    public function ride(): BelongsTo
    {
        return $this->belongsTo(Ride::class);
    }
}
