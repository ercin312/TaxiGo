<?php

namespace App\Services;

use App\Models\DeviceRegistration;
use App\Models\Ride;
use Illuminate\Support\Facades\Log;

class RideDispatchService
{
    public function __construct(
        protected RideMatchingService $matchingService,
        protected FcmPushService $fcmPush,
    ) {}

    public function notifyNearbyDrivers(Ride $ride, string $vehicleType = 'standard'): int
    {
        if (app(FeatureModuleService::class)->disabled('fcm_dispatch')) {
            return 0;
        }

        if (! $this->fcmPush->isConfigured()) {
            return 0;
        }

        $nearby = $this->matchingService->findNearbyDrivers(
            (float) $ride->pickup_latitude,
            (float) $ride->pickup_longitude,
            config('taxigo.matching.radius_km', 5.0),
            config('taxigo.matching.max_drivers', 10),
            $vehicleType,
        );

        $sent = 0;
        $fare = number_format((float) ($ride->offered_fare ?? $ride->estimated_fare ?? 0), 2);

        foreach ($nearby as $item) {
            $driver = $item['driver'];
            $user = $driver->user;
            $tokens = collect();

            if (! empty($user?->fcm_token) && ($user->is_active_device ?? true)) {
                $tokens->push($user->fcm_token);
            }

            if (! empty($user?->phone)) {
                $deviceTokens = DeviceRegistration::query()
                    ->where('phone', $user->phone)
                    ->where('is_active', true)
                    ->pluck('fcm_token');
                $tokens = $tokens->merge($deviceTokens);
            }

            foreach ($tokens->unique()->filter() as $token) {
                $ok = $this->fcmPush->sendRideRequest(
                    $token,
                    $ride->id,
                    (string) $ride->pickup_address,
                    $fare.' '.config('taxigo.currency', 'USD'),
                );
                if ($ok) {
                    $sent++;
                }
            }
        }

        Log::info('Ride dispatch FCM', [
            'ride_id' => $ride->id,
            'nearby' => $nearby->count(),
            'sent' => $sent,
        ]);

        return $sent;
    }
}
