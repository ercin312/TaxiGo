<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class MapsController extends Controller
{
    public function directions(Request $request): JsonResponse
    {
        if (app(\App\Services\FeatureModuleService::class)->disabled('directions_fare')) {
            return response()->json([
                'message' => 'Directions module is disabled.',
                'points' => [],
                'fallback' => true,
            ], 403);
        }

        $validated = $request->validate([
            'origin_lat' => ['required', 'numeric'],
            'origin_lng' => ['required', 'numeric'],
            'destination_lat' => ['required', 'numeric'],
            'destination_lng' => ['required', 'numeric'],
        ]);

        $apiKey = config('taxigo.google_maps_api_key');
        if (empty($apiKey)) {
            return response()->json([
                'message' => 'Google Maps API key not configured.',
                'points' => [],
                'fallback' => true,
            ]);
        }

        $origin = $validated['origin_lat'].','.$validated['origin_lng'];
        $destination = $validated['destination_lat'].','.$validated['destination_lng'];

        $response = Http::timeout(15)->get(
            'https://maps.googleapis.com/maps/api/directions/json',
            [
                'origin' => $origin,
                'destination' => $destination,
                'mode' => 'driving',
                'key' => $apiKey,
            ]
        );

        if ($response->failed()) {
            Log::warning('Directions API failed', ['body' => $response->body()]);

            return response()->json(['points' => [], 'fallback' => true], 502);
        }

        $data = $response->json();
        if (($data['status'] ?? '') !== 'OK') {
            return response()->json([
                'points' => [],
                'fallback' => true,
                'status' => $data['status'] ?? 'UNKNOWN',
            ]);
        }

        $polyline = $data['routes'][0]['overview_polyline']['points'] ?? null;
        $leg = $data['routes'][0]['legs'][0] ?? [];

        return response()->json([
            'points' => $polyline ? $this->decodePolyline($polyline) : [],
            'distance_meters' => $leg['distance']['value'] ?? null,
            'duration_seconds' => $leg['duration']['value'] ?? null,
            'fallback' => false,
        ]);
    }

    public function placesAutocomplete(Request $request): JsonResponse
    {
        if (app(\App\Services\FeatureModuleService::class)->disabled('places_autocomplete')) {
            return response()->json([
                'predictions' => [],
                'message' => 'Places module is disabled.',
            ], 403);
        }

        $validated = $request->validate([
            'query' => ['required', 'string', 'min:2', 'max:200'],
            'latitude' => ['sometimes', 'numeric'],
            'longitude' => ['sometimes', 'numeric'],
        ]);

        $apiKey = config('taxigo.google_maps_api_key');
        if (empty($apiKey)) {
            return response()->json([
                'predictions' => [],
                'message' => 'Google Maps API key not configured.',
            ]);
        }

        $params = [
            'input' => $validated['query'],
            'key' => $apiKey,
            'language' => 'tr',
        ];

        if (isset($validated['latitude'], $validated['longitude'])) {
            $params['location'] = $validated['latitude'].','.$validated['longitude'];
            $params['radius'] = 30000;
        }

        $response = Http::timeout(15)->get(
            'https://maps.googleapis.com/maps/api/place/autocomplete/json',
            $params
        );

        if ($response->failed()) {
            return response()->json(['predictions' => []], 502);
        }

        $predictions = collect($response->json('predictions', []))
            ->map(fn (array $p) => [
                'place_id' => $p['place_id'] ?? '',
                'description' => $p['description'] ?? '',
                'main_text' => $p['structured_formatting']['main_text'] ?? ($p['description'] ?? ''),
                'secondary_text' => $p['structured_formatting']['secondary_text'] ?? '',
            ])
            ->values();

        return response()->json(['predictions' => $predictions]);
    }

    public function placeDetails(Request $request): JsonResponse
    {
        if (app(\App\Services\FeatureModuleService::class)->disabled('places_autocomplete')) {
            return response()->json(['message' => 'Places module is disabled.'], 403);
        }

        $validated = $request->validate([
            'place_id' => ['required', 'string'],
        ]);

        $apiKey = config('taxigo.google_maps_api_key');
        if (empty($apiKey)) {
            return response()->json(['message' => 'Google Maps API key not configured.'], 503);
        }

        $response = Http::timeout(15)->get(
            'https://maps.googleapis.com/maps/api/place/details/json',
            [
                'place_id' => $validated['place_id'],
                'fields' => 'geometry,formatted_address,name',
                'key' => $apiKey,
            ]
        );

        if ($response->failed() || ($response->json('status') !== 'OK')) {
            return response()->json(['message' => 'Place not found.'], 404);
        }

        $result = $response->json('result', []);
        $location = $result['geometry']['location'] ?? [];

        return response()->json([
            'place_id' => $validated['place_id'],
            'name' => $result['name'] ?? null,
            'address' => $result['formatted_address'] ?? null,
            'latitude' => $location['lat'] ?? null,
            'longitude' => $location['lng'] ?? null,
        ]);
    }

    /**
     * @return list<array{lat: float, lng: float}>
     */
    protected function decodePolyline(string $encoded): array
    {
        $length = strlen($encoded);
        $index = 0;
        $lat = 0;
        $lng = 0;
        $points = [];

        while ($index < $length) {
            $result = 0;
            $shift = 0;
            do {
                $b = ord($encoded[$index++]) - 63;
                $result |= ($b & 0x1f) << $shift;
                $shift += 5;
            } while ($b >= 0x20);
            $dlat = ($result & 1) ? ~($result >> 1) : ($result >> 1);
            $lat += $dlat;

            $result = 0;
            $shift = 0;
            do {
                $b = ord($encoded[$index++]) - 63;
                $result |= ($b & 0x1f) << $shift;
                $shift += 5;
            } while ($b >= 0x20);
            $dlng = ($result & 1) ? ~($result >> 1) : ($result >> 1);
            $lng += $dlng;

            $points[] = [
                'lat' => $lat / 1e5,
                'lng' => $lng / 1e5,
            ];
        }

        return $points;
    }
}
