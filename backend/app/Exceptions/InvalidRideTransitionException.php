<?php

namespace App\Exceptions;

use App\Enums\RideStatus;
use Exception;

class InvalidRideTransitionException extends Exception
{
    public static function fromTransition(RideStatus $from, RideStatus $to): self
    {
        return new self("Cannot transition ride from '{$from->value}' to '{$to->value}'.");
    }
}
