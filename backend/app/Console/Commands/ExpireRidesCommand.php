<?php

namespace App\Console\Commands;

use App\Enums\RideStatus;
use App\Exceptions\InvalidRideTransitionException;
use App\Models\Ride;
use App\Services\FirebaseRtdbService;
use App\Services\RideStatusService;
use Illuminate\Console\Command;

class ExpireRidesCommand extends Command
{
    protected $signature = 'taxigo:expire-rides';

    protected $description = 'Mark pending rides past expires_at as expired';

    public function handle(RideStatusService $statusService, FirebaseRtdbService $rtdbService): int
    {
        if (app(\App\Services\FeatureModuleService::class)->disabled('ride_expiry')) {
            $this->info('Ride expiry module is disabled.');

            return self::SUCCESS;
        }

        $rides = Ride::query()
            ->where('status', RideStatus::Pending)
            ->whereNotNull('expires_at')
            ->where('expires_at', '<', now())
            ->get();

        $count = 0;

        foreach ($rides as $ride) {
            try {
                $ride = $statusService->transition($ride, RideStatus::Expired);
                $rtdbService->syncRide($ride);
                $count++;
            } catch (InvalidRideTransitionException $e) {
                $this->warn("Ride #{$ride->id}: {$e->getMessage()}");
            }
        }

        $this->info("Expired {$count} ride(s).");

        return self::SUCCESS;
    }
}
