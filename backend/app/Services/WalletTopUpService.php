<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use RuntimeException;

/**
 * Passenger wallet top-up via configured PSP (stub / iyzico).
 * Gated by FeatureModuleService key `wallet_topup`.
 */
class WalletTopUpService
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
     * Capture funds and return payment metadata for ledger credit.
     *
     * @return array{status: string, reference: string, provider: string, meta: array<string, mixed>}
     */
    public function charge(User $user, float $amount): array
    {
        if (app(FeatureModuleService::class)->disabled('wallet_topup')) {
            throw new RuntimeException('Wallet top-up module is disabled.');
        }

        if ($amount < (float) config('taxigo.wallet.min_topup', 5)) {
            throw new RuntimeException('Amount below minimum top-up.');
        }

        if (! $this->isConfigured()) {
            throw new RuntimeException('Payment provider is not configured.');
        }

        return match ($this->driver()) {
            'iyzico' => $this->chargeViaIyzico($user, $amount),
            default => $this->chargeViaStub($user, $amount),
        };
    }

    /**
     * @return array{status: string, reference: string, provider: string, meta: array<string, mixed>}
     */
    protected function chargeViaStub(User $user, float $amount): array
    {
        $reference = 'WTUP-STUB-'.strtoupper(Str::random(10));

        Log::info('Wallet top-up stub captured', [
            'user_id' => $user->id,
            'amount' => $amount,
            'reference' => $reference,
        ]);

        return [
            'status' => 'captured',
            'reference' => $reference,
            'provider' => 'stub',
            'meta' => [
                'amount' => $amount,
                'currency' => config('taxigo.currency', 'EUR'),
                'mode' => 'stub',
            ],
        ];
    }

    /**
     * @return array{status: string, reference: string, provider: string, meta: array<string, mixed>}
     */
    protected function chargeViaIyzico(User $user, float $amount): array
    {
        $baseUrl = rtrim((string) config('taxigo.payments.iyzico.base_url'), '/');
        $apiKey = (string) config('taxigo.payments.iyzico.api_key');
        $secret = (string) config('taxigo.payments.iyzico.secret_key');
        $conversationId = 'wallet-'.$user->id.'-'.Str::random(8);
        $reference = 'WTUP-IYZ-'.strtoupper(Str::random(10));

        $payload = [
            'locale' => 'en',
            'conversationId' => $conversationId,
            'price' => number_format($amount, 2, '.', ''),
            'paidPrice' => number_format($amount, 2, '.', ''),
            'currency' => config('taxigo.currency', 'EUR'),
            'basketId' => $reference,
            'paymentGroup' => 'PRODUCT',
            'buyer' => [
                'id' => (string) $user->id,
                'name' => $user->name ?? 'Passenger',
                'surname' => 'TaxiGo',
                'email' => $user->email ?: 'passenger@taxigo.app',
                'identityNumber' => '11111111111',
                'registrationAddress' => 'Montenegro',
                'city' => 'Podgorica',
                'country' => 'ME',
                'ip' => request()->ip() ?? '127.0.0.1',
            ],
        ];

        try {
            $response = Http::withBasicAuth($apiKey, $secret)
                ->acceptJson()
                ->asJson()
                ->timeout(20)
                ->post($baseUrl.'/payment/auth', $payload);

            $body = $response->json() ?? [];
            $ok = $response->successful()
                && (($body['status'] ?? '') === 'success'
                    || ($body['paymentStatus'] ?? '') === 'SUCCESS');

            Log::info('Wallet top-up iyzico response', [
                'user_id' => $user->id,
                'http' => $response->status(),
                'body_status' => $body['status'] ?? null,
            ]);

            if (! $ok) {
                // Sandbox / incomplete payload: still record pending-style stub capture
                // when driver is intentionally used for integration tests.
                throw new RuntimeException(
                    (string) ($body['errorMessage'] ?? 'iyzico top-up failed')
                );
            }

            return [
                'status' => 'captured',
                'reference' => (string) ($body['paymentId'] ?? $reference),
                'provider' => 'iyzico',
                'meta' => [
                    'amount' => $amount,
                    'currency' => config('taxigo.currency', 'EUR'),
                    'conversation_id' => $conversationId,
                    'raw_status' => $body['status'] ?? null,
                ],
            ];
        } catch (RuntimeException $e) {
            throw $e;
        } catch (\Throwable $e) {
            Log::error('Wallet top-up iyzico error', ['message' => $e->getMessage()]);
            throw new RuntimeException('Payment provider error: '.$e->getMessage());
        }
    }
}
