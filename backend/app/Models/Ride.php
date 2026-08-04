<?php

namespace App\Models;

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use App\Enums\RideStatus;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Ride extends Model
{
    protected $fillable = [
        'reference',
        'passenger_id',
        'driver_id',
        'status',
        'pickup_latitude',
        'pickup_longitude',
        'pickup_address',
        'dropoff_latitude',
        'dropoff_longitude',
        'dropoff_address',
        'estimated_distance_km',
        'estimated_duration_minutes',
        'estimated_fare',
        'offered_fare',
        'minimum_fare',
        'is_bidding',
        'final_fare',
        'distance_km',
        'duration_minutes',
        'payment_method',
        'payment_status',
        'payment_provider',
        'payment_reference',
        'payment_meta',
        'promo_code_id',
        'discount_amount',
        'commission_amount',
        'cancellation_reason',
        'driver_assigned_at',
        'driver_arrived_at',
        'started_at',
        'completed_at',
        'settled_at',
        'cancelled_at',
        'expires_at',
        'share_token',
        'share_expires_at',
    ];

    protected function casts(): array
    {
        return [
            'status' => RideStatus::class,
            'payment_method' => PaymentMethod::class,
            'payment_status' => PaymentStatus::class,
            'payment_meta' => 'array',
            'pickup_latitude' => 'decimal:7',
            'pickup_longitude' => 'decimal:7',
            'dropoff_latitude' => 'decimal:7',
            'dropoff_longitude' => 'decimal:7',
            'estimated_distance_km' => 'decimal:2',
            'estimated_fare' => 'decimal:2',
            'offered_fare' => 'decimal:2',
            'minimum_fare' => 'decimal:2',
            'is_bidding' => 'boolean',
            'final_fare' => 'decimal:2',
            'distance_km' => 'decimal:2',
            'discount_amount' => 'decimal:2',
            'commission_amount' => 'decimal:2',
            'driver_assigned_at' => 'datetime',
            'driver_arrived_at' => 'datetime',
            'started_at' => 'datetime',
            'completed_at' => 'datetime',
            'settled_at' => 'datetime',
            'cancelled_at' => 'datetime',
            'expires_at' => 'datetime',
            'share_expires_at' => 'datetime',
        ];
    }

    public function passenger(): BelongsTo
    {
        return $this->belongsTo(User::class, 'passenger_id');
    }

    public function driver(): BelongsTo
    {
        return $this->belongsTo(Driver::class);
    }

    public function promoCode(): BelongsTo
    {
        return $this->belongsTo(PromoCode::class);
    }

    public function locations(): HasMany
    {
        return $this->hasMany(RideLocation::class);
    }

    public function rating(): HasOne
    {
        return $this->hasOne(RideRating::class);
    }

    public function promoUsage(): HasOne
    {
        return $this->hasOne(PromoUsage::class);
    }

    public function bids(): HasMany
    {
        return $this->hasMany(RideBid::class);
    }

    public function complaints(): HasMany
    {
        return $this->hasMany(Complaint::class);
    }

    public function walletTransactions(): HasMany
    {
        return $this->hasMany(WalletTransaction::class);
    }
}
