<?php

namespace App\Models;

use App\Enums\RideBidStatus;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RideBid extends Model
{
    protected $fillable = [
        'ride_id',
        'driver_id',
        'amount',
        'status',
        'expires_at',
    ];

    protected function casts(): array
    {
        return [
            'status' => RideBidStatus::class,
            'amount' => 'decimal:2',
            'expires_at' => 'datetime',
        ];
    }

    public function ride(): BelongsTo
    {
        return $this->belongsTo(Ride::class);
    }

    public function driver(): BelongsTo
    {
        return $this->belongsTo(Driver::class);
    }

    public function isExpired(): bool
    {
        return $this->expires_at !== null && $this->expires_at->isPast();
    }
}
