<?php

namespace App\Models;

use App\Enums\UserRole;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

#[Fillable([
    'name',
    'email',
    'password',
    'firebase_uid',
    'phone',
    'role',
    'locale',
    'avatar',
    'is_active',
    'fcm_token',
    'fcm_token_updated_at',
    'is_active_device',
])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'role' => UserRole::class,
            'is_active' => 'boolean',
            'is_active_device' => 'boolean',
            'fcm_token_updated_at' => 'datetime',
        ];
    }

    public function driver(): HasOne
    {
        return $this->hasOne(Driver::class);
    }

    public function wallet(): HasOne
    {
        return $this->hasOne(Wallet::class);
    }

    public function passengerRides(): HasMany
    {
        return $this->hasMany(Ride::class, 'passenger_id');
    }

    public function complaints(): HasMany
    {
        return $this->hasMany(Complaint::class);
    }

    public function notifications(): HasMany
    {
        return $this->hasMany(Notification::class);
    }

    public function ratingsGiven(): HasMany
    {
        return $this->hasMany(RideRating::class, 'rater_id');
    }

    public function ratingsReceived(): HasMany
    {
        return $this->hasMany(RideRating::class, 'rated_id');
    }

    public function promoUsages(): HasMany
    {
        return $this->hasMany(PromoUsage::class);
    }

    public function isAdmin(): bool
    {
        return $this->role === UserRole::Admin || $this->role === UserRole::SuperAdmin;
    }

    public function isSuperAdmin(): bool
    {
        return $this->role === UserRole::SuperAdmin;
    }

    public function isDriver(): bool
    {
        return $this->role === UserRole::Driver;
    }

    public function isPassenger(): bool
    {
        return $this->role === UserRole::Passenger;
    }
}
