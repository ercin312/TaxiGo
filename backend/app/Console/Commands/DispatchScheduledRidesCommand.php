<?php

namespace App\Console\Commands;

use App\Enums\RideStatus;
use App\Models\Ride;
use App\Services\FirebaseRtdbService;
use App\Services\InstantMatchService;
use App\Services\RideDispatchService;
use Illuminate\Console\Command;

class DispatchScheduledRidesCommand extends Command
{
    protected $signature = 'taxigo:dispatch-scheduled';

    protected $description = 'Dispatch scheduled rides whose scheduled_at has arrived';

    public function handle(
        RideDispatchService $dispatchService,
        InstantMatchService $instantMatch,
        FirebaseRtdbService $rtdbService,
    ): int {
        $rides = Ride::query()
            ->where('status', RideStatus::Pending)
            ->whereNotNull('scheduled_at')
            ->where('scheduled_at', '<=', now())
            ->whereNull('driver_id')
            ->limit(50)
            ->get();

        foreach ($rides as $ride) {
            if (! $ride->expires_at) {
                $ride->expires_at = now()->addMinutes(config('taxigo.ride_expiry_minutes', 15));
                $ride->save();
            }

            $vehicleType = $ride->vehicle_type ?? 'standard';
            $matched = null;
            if (! $ride->is_bidding) {
                $matched = $instantMatch->tryAssignNearest($ride, $vehicleType);
            }

            if ($matched === null) {
                $dispatchService->notifyNearbyDrivers($ride, $vehicleType);
            }

            $rtdbService->syncRide($matched ?? $ride);
            $this->info("Dispatched ride #{$ride->id}");
        }

        return self::SUCCESS;
    }
}
