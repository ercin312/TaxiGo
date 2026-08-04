<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class GoogleMapsService
{
    /**
     * @return array{distance_km: float, duration_minutes: int, source: string}|null
     */
    public function routeMetrics(
        float $originLat,
        float $originLng,
        float $destinationLat,
        float $destinationLng,
    ): ?array {
        $apiKey = config('taxigo.google_maps_api_key');
        if (empty($apiKey)) {
            return null;
        }

        $response = Http::timeout(15)->get(
            'https://maps.googleapis.com/maps/api/directions/json',
            [
                'origin' => $originLat.','.$originLng,
                'destination' => $destinationLat.','.$destinationLng,
                'mode' => 'driving',
                'key' => $apiKey,
            ]
        );

        if ($response->failed()) {
            Log::warning('Directions API failed', ['body' => $response->body()]);

            return null;
        }

        $data = $response->json();
        if (($data['status'] ?? '') !== 'OK') {
            Log::info('Directions API status', ['status' => $data['status'] ?? 'UNKNOWN']);

            return null;
        }

        $leg = $data['routes'][0]['legs'][0] ?? null;
        if (! $leg) {
            return null;
        }

        $meters = (float) ($leg['distance']['value'] ?? 0);
        $seconds = (int) ($leg['duration']['value'] ?? 0);

        return [
            'distance_km' => round($meters / 1000, 2),
            'duration_minutes' => max(1, (int) ceil($seconds / 60)),
            'source' => 'directions',
        ];
    }
}
