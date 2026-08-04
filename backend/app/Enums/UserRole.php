<?php

namespace App\Enums;

enum UserRole: string
{
    case Passenger = 'passenger';
    case Driver = 'driver';
    case Admin = 'admin';
    case SuperAdmin = 'super_admin';

    public function label(): string
    {
        return match ($this) {
            self::Passenger => 'Passenger',
            self::Driver => 'Driver',
            self::Admin => 'Admin',
            self::SuperAdmin => 'Super Admin',
        };
    }
}
