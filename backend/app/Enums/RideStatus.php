<?php

namespace App\Enums;

enum RideStatus: string
{
    case Pending = 'pending';
    case DriverAssigned = 'driver_assigned';
    case DriverArriving = 'driver_arriving';
    case DriverArrived = 'driver_arrived';
    case PassengerOnBoard = 'passenger_on_board';
    case InProgress = 'in_progress';
    case Completed = 'completed';
    case CancelledByPassenger = 'cancelled_by_passenger';
    case CancelledByDriver = 'cancelled_by_driver';
    case Expired = 'expired';

    public function isTerminal(): bool
    {
        return in_array($this, [
            self::Completed,
            self::CancelledByPassenger,
            self::CancelledByDriver,
            self::Expired,
        ], true);
    }

    public function label(): string
    {
        return match ($this) {
            self::Pending => 'Pending',
            self::DriverAssigned => 'Driver Assigned',
            self::DriverArriving => 'Driver Arriving',
            self::DriverArrived => 'Driver Arrived',
            self::PassengerOnBoard => 'Passenger On Board',
            self::InProgress => 'In Progress',
            self::Completed => 'Completed',
            self::CancelledByPassenger => 'Cancelled by Passenger',
            self::CancelledByDriver => 'Cancelled by Driver',
            self::Expired => 'Expired',
        };
    }
}
