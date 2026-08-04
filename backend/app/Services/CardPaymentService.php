<?php

namespace App\Services;

use App\Enums\PaymentStatus;
use App\Models\Ride;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use RuntimeException;

/**
 * Card capture for ride completion.
 * Drivers: stub (local/dev), iyzico (TR scaffold).
 */
class CardPaymentService
{
    public function driver(): string
    {
        return (string) config('taxigo.payments.driver', 'stub');
    }

    public function isConfigured(): bool
    {
        return match ($this->driver()) {
            'stub' => true,
            'iyzico' => ! empty(config('taxigo.payments.iyzico.api_key'))
                && ! empty(config('taxigo.payments.iyzico.secret_key')),
            default => false,
        };
    }

    /**
     * Charge the passenger for the ride fare via the configured PSP.
     *
     * @return array{status: string, reference: string, provider: string, meta: array<string, mixed>}
     */
    public function charge(Ride $ride, float $amount): array
    {
        if (app(FeatureModuleService::class)->disabled('card_payments')) {
            throw new RuntimeException('Card payments module is disabled.');
        }

        if ($amount <= 0) {
            throw new RuntimeException('Invalid card charge amount.');
        }

        return match ($this->driver()) {
            'iyzico' => $this->chargeViaIyzico($ride, $amount),
            default => $this->chargeViaStub($ride, $amount),
        };
    }

    /**
     * @return array{status: string, reference: string, provider: string, meta: array<string, mixed>}
     */
    protected function chargeViaStub(Ride $ride, float $amount): array
    {
        $reference = 'STUB-'.strtoupper(Str::random(12));

        Log::info('Card payment stub captured', [
            'ride_id' => $ride->id,
            'amount' => $amount,
            'reference' => $reference,
        ]);

        return [
            'status' => PaymentStatus::Captured->value,
            'reference' => $reference,
            'provider' => 'stub',
            'meta' => [
                'amount' => $amount,
                'currency' => config('taxigo.currency', 'USD'),
                'mode' => 'stub',
            ],
        ];
    }

    /**
     * Minimal iyzico Checkout Form / payment stub using REST.
     * Real production should use official iyzipay-php; this records intent + sandbox-style response.
     *
     * @return array{status: string, reference: string, provider: string, meta: array<string, mixed>}
     */
    protected function chargeViaIyzico(Ride $ride, float $amount): array
    {
        if (! $this->isConfigured()) {
            throw new RuntimeException('iyzico is not configured. Set IYZICO_API_KEY and IYZICO_SECRET_KEY.');
        }

        $baseUrl = rtrim((string) config('taxigo.payments.iyzico.base_url'), '/');
        $apiKey = (string) config('taxigo.payments.iyzico.api_key');
        $secret = (string) config('taxigo.payments.iyzico.secret_key');
        $conversationId = 'ride-'.$ride->id.'-'.Str::random(8);

        // Sandbox-friendly placeholder payload. Replace with full Checkout Form / 3DS flow for production.
        $payload = [
            'locale' => 'tr',
            'conversationId' => $conversationId,
            'price' => number_format($amount, 2, '.', ''),
            'paidPrice' => number_format($amount, 2, '.', ''),
            'currency' => strtoupper((string) config('taxigo.currency', 'TRY')),
            'basketId' => (string) $ride->reference,
            'paymentGroup' => 'PRODUCT',
            'callbackUrl' => url('/api/v1/payments/iyzico/callback'),
        ];

        // Random string auth header pattern used by iyzico (simplified for scaffold).
        $random = Str::random(8);
        $hashStr = $apiKey.$random.$secret;
        $authorization = 'IYZWS '.$apiKey.':'.base64_encode(sha1($hashStr, true));

        try {
            $response = Http::timeout(20)
                ->withHeaders([
                    'Authorization' => $authorization,
                    'x-iyzi-rnd' => $random,
                    'Content-Type' => 'application/json',
                ])
                ->post($baseUrl.'/payment/bin/check', $payload);

            // Until full 3DS is wired, fall open to captured in non-production when API unreachable,
            // and record attempt metadata. Production requires successful provider response.
            if ($response->successful() && ($response->json('status') === 'success')) {
                return [
                    'status' => PaymentStatus::Captured->value,
                    'reference' => (string) ($response->json('paymentId') ?? $conversationId),
                    'provider' => 'iyzico',
                    'meta' => [
                        'amount' => $amount,
                        'raw_status' => $response->json('status'),
                        'conversation_id' => $conversationId,
                    ],
                ];
            }

            if (app()->environment('production')) {
                Log::warning('iyzico charge failed', ['body' => $response->body()]);

                throw new RuntimeException('Card charge failed via iyzico.');
            }

            Log::warning('iyzico unavailable — using sandbox capture fallback', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return [
                'status' => PaymentStatus::Captured->value,
                'reference' => 'IYZ-FALLBACK-'.$conversationId,
                'provider' => 'iyzico',
                'meta' => [
                    'amount' => $amount,
                    'fallback' => true,
                    'conversation_id' => $conversationId,
                ],
            ];
        } catch (RuntimeException $e) {
            throw $e;
        } catch (\Throwable $e) {
            if (app()->environment('production')) {
                throw new RuntimeException('Card charge failed: '.$e->getMessage());
            }

            return [
                'status' => PaymentStatus::Captured->value,
                'reference' => 'IYZ-ERR-'.$conversationId,
                'provider' => 'iyzico',
                'meta' => [
                    'amount' => $amount,
                    'fallback' => true,
                    'error' => $e->getMessage(),
                ],
            ];
        }
    }

    /**
     * Mark webhook / callback capture (idempotent).
     *
     * @param  array<string, mixed>  $meta
     */
    public function markCaptured(Ride $ride, string $reference, array $meta = []): Ride
    {
        $ride->update([
            'payment_status' => PaymentStatus::Captured,
            'payment_reference' => $reference,
            'payment_provider' => $ride->payment_provider ?: $this->driver(),
            'payment_meta' => array_merge($ride->payment_meta ?? [], $meta),
        ]);

        return $ride->fresh();
    }
}
