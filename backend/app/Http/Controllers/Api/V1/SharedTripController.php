<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Ride;
use App\Services\FeatureModuleService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SharedTripController extends Controller
{
    public function show(Request $request, string $reference): JsonResponse
    {
        if (app(FeatureModuleService::class)->disabled('share_trip')) {
            return response()->json(['message' => 'Share trip module is disabled.'], 403);
        }

        $token = (string) $request->query('token', '');
        $ride = Ride::query()
            ->where('reference', $reference)
            ->with(['driver.user', 'driver.vehicle'])
            ->first();

        if (! $ride || empty($ride->share_token) || ! hash_equals($ride->share_token, $token)) {
            return response()->json(['message' => 'Shared trip not found.'], 404);
        }

        if ($ride->share_expires_at && $ride->share_expires_at->isPast()) {
            return response()->json(['message' => 'Shared trip link expired.'], 410);
        }

        $driverLocation = null;
        if ($ride->driver) {
            $driverLocation = [
                'latitude' => $ride->driver->current_latitude,
                'longitude' => $ride->driver->current_longitude,
                        'updated_at' => $ride->driver->last_location_at,
            ];
        }

        return response()->json([
            'ride' => [
                'reference' => $ride->reference,
                'status' => $ride->status->value,
                'pickup_address' => $ride->pickup_address,
                'dropoff_address' => $ride->dropoff_address,
                'pickup_latitude' => $ride->pickup_latitude,
                'pickup_longitude' => $ride->pickup_longitude,
                'dropoff_latitude' => $ride->dropoff_latitude,
                'dropoff_longitude' => $ride->dropoff_longitude,
                'driver' => $ride->driver ? [
                    'name' => $ride->driver->user?->name,
                    'vehicle' => $ride->driver->vehicle ? [
                        'make' => $ride->driver->vehicle->make ?? null,
                        'model' => $ride->driver->vehicle->model ?? null,
                        'plate' => $ride->driver->vehicle->plate_number ?? null,
                        'color' => $ride->driver->vehicle->color ?? null,
                    ] : null,
                ] : null,
                'driver_location' => $driverLocation,
                'expires_at' => $ride->share_expires_at?->toIso8601String(),
            ],
        ]);
    }

    public function page(Request $request, string $reference)
    {
        if (app(FeatureModuleService::class)->disabled('share_trip')) {
            abort(403, 'Share trip module is disabled.');
        }

        $token = (string) $request->query('token', '');
        $ride = Ride::query()->where('reference', $reference)->first();

        if (! $ride || empty($ride->share_token) || ! hash_equals($ride->share_token, $token)) {
            abort(404, 'Shared trip not found.');
        }

        if ($ride->share_expires_at && $ride->share_expires_at->isPast()) {
            abort(410, 'Shared trip link expired.');
        }

        return view('shared-trip', [
            'reference' => $reference,
            'token' => $token,
            'apiUrl' => url("/api/v1/shared/trips/{$reference}?token={$token}"),
        ]);
    }
}
