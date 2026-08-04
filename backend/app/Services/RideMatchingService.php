<?php

namespace App\Services;

use App\Enums\DriverApprovalStatus;
use App\Models\Driver;
use Illuminate\Support\Collection;

class RideMatchingService
{
    public function __construct(
        protected FareCalculatorService $fareCalculator,
    ) {}

    public function findNearbyDrivers(
        float $latitude,
        float $longitude,
        float $radiusKm = 5.0,
        int $limit = 10,
        string $vehicleType = 'standard',
    ): Collection {
        $radiusKm = $radiusKm > 0 ? $radiusKm : config('taxigo.matching.radius_km', 5.0);

        $drivers = Driver::query()
            ->with(['user', 'vehicle'])
            ->where('approval_status', DriverApprovalStatus::Approved)
            ->where('is_online', true)
            ->whereNotNull('current_latitude')
            ->whereNotNull('current_longitude')
            ->whereHas('vehicle', function ($query) use ($vehicleType) {
                $query->where('is_active', true)
                    ->where('vehicle_type', $vehicleType);
            })
            ->get();

        return $drivers
            ->map(function (Driver $driver) use ($latitude, $longitude) {
                $distance = $this->fareCalculator->haversineDistance(
                    $latitude,
                    $longitude,
                    (float) $driver->current_latitude,
                    (float) $driver->current_longitude,
                );

                return [
                    'driver' => $driver,
                    'distance_km' => $distance,
                ];
            })
            ->filter(fn (array $item) => $item['distance_km'] <= $radiusKm)
            ->sortBy('distance_km')
            ->take($limit)
            ->values();
    }

    public function distanceKm(
        float $lat1,
        float $lng1,
        float $lat2,
        float $lng2,
    ): float {
        return $this->fareCalculator->haversineDistance($lat1, $lng1, $lat2, $lng2);
    }

    public function findNearestDriver(
        float $latitude,
        float $longitude,
        float $radiusKm = 5.0,
        string $vehicleType = 'standard',
    ): ?Driver {
        $result = $this->findNearbyDrivers($latitude, $longitude, $radiusKm, 1, $vehicleType);

        return $result->first()['driver'] ?? null;
    }

    public function updateDriverLocation(Driver $driver, float $latitude, float $longitude, ?float $heading = null): Driver
    {
        $driver->update([
            'current_latitude' => $latitude,
            'current_longitude' => $longitude,
            'heading' => $heading,
            'last_location_at' => now(),
        ]);

        return $driver->fresh();
    }

    public function getOnlineDriverCount(): int
    {
        return Driver::query()
            ->where('approval_status', DriverApprovalStatus::Approved)
            ->where('is_online', true)
            ->count();
    }

    public function getDriversInBoundingBox(float $minLat, float $maxLat, float $minLng, float $maxLng): Collection
    {
        return Driver::query()
            ->with(['user', 'vehicle'])
            ->where('approval_status', DriverApprovalStatus::Approved)
            ->where('is_online', true)
            ->whereBetween('current_latitude', [$minLat, $maxLat])
            ->whereBetween('current_longitude', [$minLng, $maxLng])
            ->get();
    }
}
