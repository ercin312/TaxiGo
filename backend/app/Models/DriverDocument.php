<?php

namespace App\Models;

use App\Enums\DocumentType;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DriverDocument extends Model
{
    protected $fillable = [
        'driver_id',
        'type',
        'file_path',
        'original_name',
        'status',
        'rejection_reason',
        'verified_at',
    ];

    protected function casts(): array
    {
        return [
            'type' => DocumentType::class,
            'verified_at' => 'datetime',
        ];
    }

    public function driver(): BelongsTo
    {
        return $this->belongsTo(Driver::class);
    }
}
