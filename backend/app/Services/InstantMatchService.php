<?php

namespace App\Services;

use App\Enums\RideStatus;
use App\Exceptions\InvalidRideTransitionException;
use App\Models\DeviceRegistration;
use App\Models\Ride;
use Illuminate\Support\Facades\Log;

/**
 * Auto-assign nearest available driver for non-bidding (instant) rides.
 */
class InstantMatchService
{
    public function __construct(
        protected RideMatchingService $matchingService,
        protected RideStatusService $statusService,
        protected FcmPushService $fcmPush,
    ) {}

    /**
     * Try to assign the nearest online driver. Returns updated ride or null.
     */
    public function tryAssignNearest(Ride $ride, string $vehicleType = 'standard'): ?Ride
    {
        if ($ride->is_bidding || $ride->driver_id !== null) {
            return null;
        }

        if ($ride->status !== RideStatus::Pending) {
            return null;
        }

        $driver = $this->matchingService->findNearestDriver(
            (float) $ride->pickup_latitude,
            (float) $ride->pickup_longitude,
            (float) config('taxigo.matching.radius_km', 5.0),
            $vehicleType,
        );

        if ($driver === null) {
            Log::info('Instant match: no nearby driver', ['ride_id' => $ride->id]);

            return null;
        }

        try {
            $ride = $this->statusService->transition($ride, RideStatus::DriverAssigned, [
                'driver_id' => $driver->id,
            ]);
            $ride = $this->statusService->transition($ride, RideStatus::DriverArriving);
        } catch (InvalidRideTransitionException $e) {
            Log::warning('Instant match transition failed', [
                'ride_id' => $ride->id,
                'message' => $e->getMessage(),
            ]);

            return null;
        }

        $this->notifyAssignedDriver($ride, $driver->user?->fcm_token, $driver->user?->phone);

        Log::info('Instant match assigned', [
            'ride_id' => $ride->id,
            'driver_id' => $driver->id,
        ]);

        return $ride->load(['passenger', 'driver.user', 'driver.vehicle']);
    }

    protected function notifyAssignedDriver(Ride $ride, ?string $fcmToken, ?string $phone): void
    {
        if (app(FeatureModuleService::class)->disabled('fcm_dispatch')) {
            return;
        }

        if (! $this->fcmPush->isConfigured()) {
            return;
        }

        $tokens = collect();
        if (! empty($fcmToken)) {
            $tokens->push($fcmToken);
        }
        if (! empty($phone)) {
            $tokens = $tokens->merge(
                DeviceRegistration::query()
                    ->where('phone', $phone)
                    ->where('is_active', true)
                    ->pluck('fcm_token')
            );
        }

        $fare = number_format((float) ($ride->offered_fare ?? $ride->estimated_fare ?? 0), 2)
            .' '.config('taxigo.currency', 'EUR');

        foreach ($tokens->unique()->filter() as $token) {
            $this->fcmPush->send(
                token: $token,
                title: 'New ride assigned',
                body: (string) $ride->pickup_address.' — '.$fare,
                data: [
                    'type' => 'ride_assigned',
                    'ride_id' => (string) $ride->id,
                ],
                channelId: 'taxigo_rides',
                sound: true,
            );
        }
    }
}
