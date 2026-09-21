<?php

namespace App\Services;

use App\Enums\RideStatus;
use App\Models\Ride;
use RuntimeException;

class RideReceiptService
{
    /**
     * @return array<string, mixed>
     */
    public function build(Ride $ride): array
    {
        if (app(FeatureModuleService::class)->disabled('ride_receipts')) {
            throw new RuntimeException('E-receipts module is disabled.');
        }

        if ($ride->status !== RideStatus::Completed) {
            throw new RuntimeException('Receipt is only available for completed rides.');
        }

        $ride->loadMissing(['passenger', 'driver.user', 'driver.vehicle', 'promoCode']);

        $fare = (float) ($ride->final_fare ?? $ride->offered_fare ?? $ride->estimated_fare ?? 0);
        $discount = (float) ($ride->discount_amount ?? 0);
        $subtotal = max(0, $fare + $discount);
        $currency = (string) config('taxigo.currency', 'EUR');
        $company = config('taxigo.company', []);

        return [
            'receipt_number' => 'RCP-'.$ride->reference,
            'issued_at' => now()->toIso8601String(),
            'company' => [
                'name' => $company['name'] ?? config('app.name', 'TaxiGo'),
                'address' => $company['address'] ?? null,
                'tax_id' => $company['tax_id'] ?? null,
                'email' => $company['email'] ?? config('taxigo.support_email'),
                'phone' => $company['phone'] ?? null,
            ],
            'ride' => [
                'id' => $ride->id,
                'reference' => $ride->reference,
                'completed_at' => $ride->completed_at?->toIso8601String(),
                'started_at' => $ride->started_at?->toIso8601String(),
                'product_mode' => $ride->product_mode ?? 'taxi',
                'vehicle_type' => $ride->vehicle_type ?? 'standard',
                'pickup_address' => $ride->pickup_address,
                'dropoff_address' => $ride->dropoff_address,
                'distance_km' => (float) ($ride->distance_km ?? $ride->estimated_distance_km ?? 0),
                'duration_minutes' => (int) ($ride->duration_minutes ?? $ride->estimated_duration_minutes ?? 0),
                'payment_method' => $ride->payment_method?->value ?? 'cash',
                'payment_status' => $ride->payment_status?->value ?? null,
            ],
            'passenger' => [
                'name' => $ride->passenger?->name,
                'phone_masked' => $this->maskPhone($ride->passenger?->phone),
            ],
            'driver' => [
                'name' => $ride->driver?->user?->name,
                'vehicle_plate' => $ride->driver?->vehicle?->plate_number,
                'vehicle_model' => trim(
                    ($ride->driver?->vehicle?->make ?? '').' '.($ride->driver?->vehicle?->model ?? '')
                ) ?: null,
            ],
            'amounts' => [
                'currency' => $currency,
                'subtotal' => round($subtotal, 2),
                'discount' => round($discount, 2),
                'total' => round($fare, 2),
                'promo_code' => $ride->promoCode?->code,
            ],
            'notes' => [
                'This is an electronic receipt for expense / business travel purposes.',
                'Phone numbers are masked for privacy.',
            ],
        ];
    }

    protected function maskPhone(?string $phone): ?string
    {
        if ($phone === null || $phone === '') {
            return null;
        }
        $digits = preg_replace('/\D+/', '', $phone) ?? '';
        if (strlen($digits) < 4) {
            return '****';
        }

        return str_repeat('*', max(0, strlen($digits) - 4)).substr($digits, -4);
    }
}
