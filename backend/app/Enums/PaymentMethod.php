<?php

namespace App\Enums;

enum PaymentMethod: string
{
    case Cash = 'cash';
    case Wallet = 'wallet';
    case Card = 'card';

    public function label(): string
    {
        return match ($this) {
            self::Cash => 'Cash',
            self::Wallet => 'Wallet',
            self::Card => 'Card',
        };
    }
}
