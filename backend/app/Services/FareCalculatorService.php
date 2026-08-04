<?php

namespace App\Services;

use App\Models\FareTariff;
use App\Models\PromoCode;

class FareCalculatorService
{
    public function calculate(
        float $distanceKm,
        int $durationMinutes,
        string $vehicleType = 'standard',
        ?PromoCode $promoCode = null,
    ): array {
        $tariff = FareTariff::query()
            ->where('vehicle_type', $vehicleType)
            ->where('is_active', true)
            ->first();

        if (! $tariff) {
            $tariff = new FareTariff([
                'base_fare' => config('taxigo.fare.base_fare', 2.50),
                'per_km_rate' => config('taxigo.fare.per_km_rate', 1.20),
                'per_minute_rate' => config('taxigo.fare.per_minute_rate', 0.25),
                'minimum_fare' => config('taxigo.fare.minimum_fare', 5.00),
                'surge_multiplier' => 1.0,
                'currency' => config('taxigo.currency', 'USD'),
            ]);
        }

        $subtotal = (float) $tariff->base_fare
            + ($distanceKm * (float) $tariff->per_km_rate)
            + ($durationMinutes * (float) $tariff->per_minute_rate);

        $subtotal *= (float) $tariff->surge_multiplier;
        $fare = max($subtotal, (float) $tariff->minimum_fare);
        $discount = 0.0;

        if ($promoCode && $promoCode->isValid()) {
            $discount = $this->calculateDiscount($fare, $promoCode);
        }

        $finalFare = max($fare - $discount, 0);
        $commissionRate = (float) config('taxigo.commission_rate', 0.15);
        $commission = round($finalFare * $commissionRate, 2);

        return [
            'distance_km' => round($distanceKm, 2),
            'duration_minutes' => $durationMinutes,
            'subtotal' => round($fare, 2),
            'discount' => round($discount, 2),
            'fare' => round($finalFare, 2),
            'commission' => $commission,
            'currency' => $tariff->currency ?? config('taxigo.currency', 'USD'),
            'tariff_id' => $tariff->id ?? null,
            'surge_multiplier' => (float) $tariff->surge_multiplier,
        ];
    }

    public function calculateDiscount(float $fare, PromoCode $promoCode): float
    {
        if ($promoCode->min_fare && $fare < (float) $promoCode->min_fare) {
            return 0.0;
        }

        $discount = match ($promoCode->discount_type) {
            'percentage' => $fare * ((float) $promoCode->discount_value / 100),
            'fixed' => (float) $promoCode->discount_value,
            default => 0.0,
        };

        if ($promoCode->max_discount) {
            $discount = min($discount, (float) $promoCode->max_discount);
        }

        return min($discount, $fare);
    }

    public function estimateEta(float $distanceKm, float $averageSpeedKmh = 30.0): int
    {
        if ($averageSpeedKmh <= 0) {
            return (int) config('taxigo.default_eta_minutes', 10);
        }

        return max(1, (int) ceil(($distanceKm / $averageSpeedKmh) * 60));
    }

    public function haversineDistance(
        float $lat1,
        float $lng1,
        float $lat2,
        float $lng2,
    ): float {
        $earthRadius = 6371;

        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);

        $a = sin($dLat / 2) ** 2
            + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLng / 2) ** 2;

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return round($earthRadius * $c, 2);
    }
}
