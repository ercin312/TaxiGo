<?php

namespace App\Services;

use App\Models\Ride;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FirebaseRtdbService
{
    public function syncRide(Ride $ride): bool
    {
        if (app(FeatureModuleService::class)->disabled('rtdb_sync')) {
            return false;
        }

        $databaseUrl = rtrim(config('taxigo.firebase.database_url', ''), '/');
        $secret = config('taxigo.firebase.database_secret');

        if (empty($databaseUrl)) {
            return false;
        }

        $url = "{$databaseUrl}/rides/{$ride->id}.json";

        if ($secret) {
            $url .= '?auth='.$secret;
        }

        $payload = [
            'ride_id' => $ride->id,
            'reference' => $ride->reference,
            'status' => $ride->status->value,
            'passenger_id' => $ride->passenger_id,
            'driver_id' => $ride->driver_id,
            'pickup' => [
                'latitude' => (float) $ride->pickup_latitude,
                'longitude' => (float) $ride->pickup_longitude,
                'address' => $ride->pickup_address,
            ],
            'dropoff' => [
                'latitude' => (float) $ride->dropoff_latitude,
                'longitude' => (float) $ride->dropoff_longitude,
                'address' => $ride->dropoff_address,
            ],
            'updated_at' => now()->toIso8601String(),
        ];

        $response = Http::timeout(10)->put($url, $payload);

        if (! $response->successful()) {
            Log::warning('Firebase RTDB sync failed', [
                'ride_id' => $ride->id,
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return false;
        }

        return true;
    }

    public function syncDriverLocation(int $driverId, float $latitude, float $longitude, ?float $heading = null): bool
    {
        $databaseUrl = rtrim(config('taxigo.firebase.database_url', ''), '/');
        $secret = config('taxigo.firebase.database_secret');

        if (empty($databaseUrl)) {
            return false;
        }

        $url = "{$databaseUrl}/drivers/{$driverId}/location.json";

        if ($secret) {
            $url .= '?auth='.$secret;
        }

        $response = Http::timeout(10)->put($url, [
            'latitude' => $latitude,
            'longitude' => $longitude,
            'heading' => $heading,
            'updated_at' => now()->toIso8601String(),
        ]);

        return $response->successful();
    }

    public function removeRide(int $rideId): bool
    {
        $databaseUrl = rtrim(config('taxigo.firebase.database_url', ''), '/');
        $secret = config('taxigo.firebase.database_secret');

        if (empty($databaseUrl)) {
            return false;
        }

        $url = "{$databaseUrl}/rides/{$rideId}.json";

        if ($secret) {
            $url .= '?auth='.$secret;
        }

        return Http::timeout(10)->delete($url)->successful();
    }
}
