<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RideRating extends Model
{
    protected $fillable = [
        'ride_id',
        'rater_id',
        'rated_id',
        'rating',
        'comment',
    ];

    public function ride(): BelongsTo
    {
        return $this->belongsTo(Ride::class);
    }

    public function rater(): BelongsTo
    {
        return $this->belongsTo(User::class, 'rater_id');
    }

    public function rated(): BelongsTo
    {
        return $this->belongsTo(User::class, 'rated_id');
    }
}
