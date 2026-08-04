<?php

namespace App\Enums;

enum RideBidStatus: string
{
    case Pending = 'pending';
    case Accepted = 'accepted';
    case Rejected = 'rejected';
    case Withdrawn = 'withdrawn';
    case Expired = 'expired';

    public function isActive(): bool
    {
        return $this === self::Pending;
    }
}
