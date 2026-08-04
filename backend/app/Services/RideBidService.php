<?php

namespace App\Services;

use App\Enums\RideBidStatus;
use App\Enums\RideStatus;
use App\Exceptions\InvalidRideTransitionException;
use App\Models\Driver;
use App\Models\Ride;
use App\Models\RideBid;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class RideBidService
{
    public function __construct(
        protected RideStatusService $statusService,
        protected FirebaseRtdbService $rtdbService,
    ) {}

    public function expireStaleBids(Ride $ride): void
    {
        RideBid::query()
            ->where('ride_id', $ride->id)
            ->where('status', RideBidStatus::Pending)
            ->where('expires_at', '<', now())
            ->update(['status' => RideBidStatus::Expired]);
    }

    public function listActiveBids(Ride $ride): Collection
    {
        $this->expireStaleBids($ride);

        return RideBid::query()
            ->where('ride_id', $ride->id)
            ->where('status', RideBidStatus::Pending)
            ->where(function ($query) {
                $query->whereNull('expires_at')
                    ->orWhere('expires_at', '>', now());
            })
            ->with(['driver.user', 'driver.vehicle'])
            ->latest()
            ->get();
    }

    public function submitBid(Ride $ride, Driver $driver, float $amount): RideBid
    {
        if ($ride->status !== RideStatus::Pending || $ride->driver_id !== null) {
            throw new \RuntimeException('Ride is no longer accepting bids.');
        }

        $minimum = (float) ($ride->minimum_fare ?? $ride->offered_fare ?? $ride->estimated_fare);

        if ($amount < $minimum) {
            throw new \InvalidArgumentException(
                "Bid amount must be at least {$minimum}."
            );
        }

        $ttl = config('taxigo.bidding.bid_ttl_seconds', 30);

        return RideBid::query()->updateOrCreate(
            [
                'ride_id' => $ride->id,
                'driver_id' => $driver->id,
            ],
            [
                'amount' => $amount,
                'status' => RideBidStatus::Pending,
                'expires_at' => now()->addSeconds($ttl),
            ],
        )->load('driver.user', 'driver.vehicle');
    }

    public function acceptBid(Ride $ride, RideBid $bid): Ride
    {
        if ($bid->ride_id !== $ride->id) {
            throw new \RuntimeException('Bid does not belong to this ride.');
        }

        if ($ride->status !== RideStatus::Pending || $ride->driver_id !== null) {
            throw new \RuntimeException('Ride is no longer available.');
        }

        if ($bid->status !== RideBidStatus::Pending || $bid->isExpired()) {
            throw new \RuntimeException('Bid is no longer valid.');
        }

        return DB::transaction(function () use ($ride, $bid) {
            $ride = Ride::query()->lockForUpdate()->findOrFail($ride->id);

            if ($ride->status !== RideStatus::Pending || $ride->driver_id !== null) {
                throw new \RuntimeException('Ride is no longer available.');
            }

            $bid->update(['status' => RideBidStatus::Accepted]);

            RideBid::query()
                ->where('ride_id', $ride->id)
                ->where('id', '!=', $bid->id)
                ->where('status', RideBidStatus::Pending)
                ->update(['status' => RideBidStatus::Rejected]);

            $ride->update([
                'estimated_fare' => $bid->amount,
                'offered_fare' => $bid->amount,
            ]);

            try {
                $ride = $this->statusService->transition($ride, RideStatus::DriverAssigned, [
                    'driver_id' => $bid->driver_id,
                ]);
                $ride = $this->statusService->transition($ride, RideStatus::DriverArriving);
            } catch (InvalidRideTransitionException $e) {
                throw new \RuntimeException($e->getMessage());
            }

            $this->rtdbService->syncRide($ride);

            return $ride->load('passenger', 'driver.user', 'driver.vehicle');
        });
    }

    public function rejectBid(RideBid $bid): RideBid
    {
        if ($bid->status !== RideBidStatus::Pending) {
            throw new \RuntimeException('Bid is no longer pending.');
        }

        $bid->update(['status' => RideBidStatus::Rejected]);

        return $bid->fresh();
    }

    public function updateOffer(Ride $ride, float $offeredFare): Ride
    {
        if ($ride->status !== RideStatus::Pending || $ride->driver_id !== null) {
            throw new \RuntimeException('Cannot update offer for this ride.');
        }

        $minimum = (float) ($ride->minimum_fare ?? $ride->estimated_fare);

        if ($offeredFare < $minimum) {
            throw new \InvalidArgumentException(
                "Offered fare must be at least {$minimum}."
            );
        }

        $ride->update([
            'offered_fare' => $offeredFare,
            'estimated_fare' => $offeredFare,
        ]);

        $this->rtdbService->syncRide($ride);

        return $ride->fresh();
    }
}
