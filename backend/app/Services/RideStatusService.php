<?php

namespace App\Services;

use App\Enums\RideStatus;
use App\Exceptions\InvalidRideTransitionException;
use App\Models\Ride;
use Illuminate\Support\Facades\DB;

class RideStatusService
{
    /** @var array<string, list<string>> */
    protected array $transitions = [
        'pending' => ['driver_assigned', 'cancelled_by_passenger', 'expired'],
        'driver_assigned' => ['driver_arriving', 'cancelled_by_passenger', 'cancelled_by_driver', 'expired'],
        'driver_arriving' => ['driver_arrived', 'cancelled_by_passenger', 'cancelled_by_driver'],
        'driver_arrived' => ['passenger_on_board', 'cancelled_by_passenger', 'cancelled_by_driver'],
        'passenger_on_board' => ['in_progress', 'cancelled_by_passenger', 'cancelled_by_driver'],
        'in_progress' => ['completed', 'cancelled_by_driver'],
        'completed' => [],
        'cancelled_by_passenger' => [],
        'cancelled_by_driver' => [],
        'expired' => [],
    ];

    public function canTransition(RideStatus $from, RideStatus $to): bool
    {
        $allowed = $this->transitions[$from->value] ?? [];

        return in_array($to->value, $allowed, true);
    }

    public function transition(Ride $ride, RideStatus $to, array $attributes = []): Ride
    {
        $from = $ride->status;

        if (! $this->canTransition($from, $to)) {
            throw InvalidRideTransitionException::fromTransition($from, $to);
        }

        return DB::transaction(function () use ($ride, $to, $attributes) {
            $timestampFields = match ($to) {
                RideStatus::DriverAssigned => ['driver_assigned_at' => now()],
                RideStatus::DriverArrived => ['driver_arrived_at' => now()],
                RideStatus::InProgress => ['started_at' => now()],
                RideStatus::Completed => ['completed_at' => now()],
                RideStatus::CancelledByPassenger,
                RideStatus::CancelledByDriver,
                RideStatus::Expired => ['cancelled_at' => now()],
                default => [],
            };

            $ride->update(array_merge(
                ['status' => $to],
                $timestampFields,
                $attributes,
            ));

            return $ride->fresh();
        });
    }

    public function allowedTransitions(RideStatus $status): array
    {
        return array_map(
            fn (string $value) => RideStatus::from($value),
            $this->transitions[$status->value] ?? [],
        );
    }
}
