<?php

namespace App\Enums;

enum DocumentType: string
{
    case Identity = 'identity';
    case License = 'license';
    case Registration = 'registration';
    case VehiclePhoto = 'vehicle_photo';

    public function label(): string
    {
        return match ($this) {
            self::Identity => 'Kimlik Belgesi',
            self::License => 'Ehliyet',
            self::Registration => 'Ruhsat / Araç Tescil',
            self::VehiclePhoto => 'Araç Fotoğrafı',
        };
    }
}
