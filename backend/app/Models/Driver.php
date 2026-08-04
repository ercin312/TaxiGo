<?php

namespace App\Models;

use App\Enums\DriverApprovalStatus;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Driver extends Model
{
    protected $fillable = [
        'user_id',
        'approval_status',
        'is_online',
        'current_latitude',
        'current_longitude',
        'heading',
        'rating_average',
        'rating_count',
        'total_rides',
        'last_location_at',
        'approved_at',
        'rejection_reason',
    ];

    protected function casts(): array
    {
        return [
            'approval_status' => DriverApprovalStatus::class,
            'is_online' => 'boolean',
            'current_latitude' => 'decimal:7',
            'current_longitude' => 'decimal:7',
            'heading' => 'decimal:2',
            'rating_average' => 'decimal:2',
            'last_location_at' => 'datetime',
            'approved_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function vehicle(): HasOne
    {
        return $this->hasOne(Vehicle::class);
    }

    public function documents(): HasMany
    {
        return $this->hasMany(DriverDocument::class);
    }

    public function rides(): HasMany
    {
        return $this->hasMany(Ride::class);
    }

    public function withdrawalRequests(): HasMany
    {
        return $this->hasMany(WithdrawalRequest::class);
    }

    public function isApproved(): bool
    {
        return $this->approval_status === DriverApprovalStatus::Approved;
    }
}
