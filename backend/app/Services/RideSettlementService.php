<?php

namespace App\Services;

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use App\Models\Ride;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use RuntimeException;

class RideSettlementService
{
    public function __construct(
        protected CardPaymentService $cardPayment,
    ) {}

    public function settle(Ride $ride): Ride
    {
        if (app(FeatureModuleService::class)->disabled('ride_settlement')) {
            return $ride;
        }

        if ($ride->settled_at) {
            return $ride;
        }

        $fare = (float) ($ride->final_fare ?? $ride->estimated_fare ?? 0);
        if ($fare <= 0) {
            throw new RuntimeException('Ride fare is missing.');
        }

        $commissionRate = (float) (
            \App\Models\Setting::getValue('commission_rate', config('taxigo.commission_rate', 0.15))
        );
        $commission = round($fare * $commissionRate, 2);
        $driverNet = round($fare - $commission, 2);
        $method = $ride->payment_method instanceof PaymentMethod
            ? $ride->payment_method
            : PaymentMethod::tryFrom((string) $ride->payment_method) ?? PaymentMethod::Cash;

        return DB::transaction(function () use ($ride, $fare, $commission, $driverNet, $method) {
            $ride = Ride::query()->lockForUpdate()->findOrFail($ride->id);

            if ($ride->settled_at) {
                return $ride;
            }

            $passenger = $ride->passenger()->lockForUpdate()->first();
            $driver = $ride->driver()->with('user')->first();

            if (! $passenger || ! $driver?->user) {
                throw new RuntimeException('Ride participants missing for settlement.');
            }

            $driverWallet = $this->lockWallet($driver->user_id);
            $paymentStatus = PaymentStatus::SettledOffline;
            $paymentFields = [];

            match ($method) {
                PaymentMethod::Wallet => $this->settleWallet(
                    passengerId: $passenger->id,
                    driverWallet: $driverWallet,
                    fare: $fare,
                    driverNet: $driverNet,
                    commission: $commission,
                    ride: $ride,
                ),
                PaymentMethod::Card => $paymentFields = $this->settleCard(
                    ride: $ride,
                    driverWallet: $driverWallet,
                    fare: $fare,
                    driverNet: $driverNet,
                    commission: $commission,
                ),
                PaymentMethod::Cash => $this->creditDriver(
                    wallet: $driverWallet,
                    amount: $driverNet,
                    ride: $ride,
                    description: 'Cash ride earning (net)',
                    type: 'ride_earning',
                ),
            };

            if ($method === PaymentMethod::Cash) {
                $paymentStatus = PaymentStatus::SettledOffline;
            } elseif ($method === PaymentMethod::Wallet) {
                $paymentStatus = PaymentStatus::Captured;
            }

            $ride->update(array_merge([
                'commission_amount' => $commission,
                'settled_at' => now(),
                'payment_status' => $paymentFields['payment_status'] ?? $paymentStatus,
            ], $paymentFields));

            return $ride->fresh();
        });
    }

    /**
     * @return array{payment_status: PaymentStatus, payment_provider: string, payment_reference: string, payment_meta: array<string, mixed>}
     */
    protected function settleCard(
        Ride $ride,
        Wallet $driverWallet,
        float $fare,
        float $driverNet,
        float $commission,
    ): array {
        if (app(FeatureModuleService::class)->disabled('card_payments')) {
            throw new RuntimeException('Card payments module is disabled.');
        }

        $alreadyCaptured = $ride->payment_status === PaymentStatus::Captured
            || $ride->payment_status === PaymentStatus::Captured->value;

        if (! $alreadyCaptured) {
            $charge = $this->cardPayment->charge($ride, $fare);
            $status = PaymentStatus::tryFrom($charge['status']) ?? PaymentStatus::Captured;
            if ($status !== PaymentStatus::Captured) {
                throw new RuntimeException('Card payment was not captured.');
            }

            $this->creditDriver(
                wallet: $driverWallet,
                amount: $driverNet,
                ride: $ride,
                description: 'Card ride earning (net of commission)',
                type: 'ride_earning',
            );

            return [
                'payment_status' => PaymentStatus::Captured,
                'payment_provider' => $charge['provider'],
                'payment_reference' => $charge['reference'],
                'payment_meta' => array_merge($charge['meta'], [
                    'commission' => $commission,
                    'driver_net' => $driverNet,
                ]),
            ];
        }

        $this->creditDriver(
            wallet: $driverWallet,
            amount: $driverNet,
            ride: $ride,
            description: 'Card ride earning (net of commission)',
            type: 'ride_earning',
        );

        return [
            'payment_status' => PaymentStatus::Captured,
            'payment_provider' => (string) ($ride->payment_provider ?: $this->cardPayment->driver()),
            'payment_reference' => (string) ($ride->payment_reference ?: 'EXISTING'),
            'payment_meta' => array_merge($ride->payment_meta ?? [], [
                'commission' => $commission,
                'driver_net' => $driverNet,
            ]),
        ];
    }

    protected function settleWallet(
        int $passengerId,
        Wallet $driverWallet,
        float $fare,
        float $driverNet,
        float $commission,
        Ride $ride,
    ): void {
        $passengerWallet = $this->lockWallet($passengerId);

        if ((float) $passengerWallet->balance < $fare) {
            throw new RuntimeException('Insufficient wallet balance.');
        }

        $newPassengerBalance = round((float) $passengerWallet->balance - $fare, 2);
        $passengerWallet->update(['balance' => $newPassengerBalance]);

        WalletTransaction::query()->create([
            'wallet_id' => $passengerWallet->id,
            'type' => 'ride_payment',
            'amount' => -$fare,
            'balance_after' => $newPassengerBalance,
            'description' => 'Ride payment',
            'ride_id' => $ride->id,
            'reference' => 'RP-'.strtoupper(Str::random(10)),
            'metadata' => [
                'commission' => $commission,
                'driver_net' => $driverNet,
            ],
        ]);

        $this->creditDriver(
            wallet: $driverWallet,
            amount: $driverNet,
            ride: $ride,
            description: 'Ride earning (net of commission)',
            type: 'ride_earning',
        );
    }

    protected function creditDriver(
        Wallet $wallet,
        float $amount,
        Ride $ride,
        string $description,
        string $type,
    ): void {
        if ($amount <= 0) {
            return;
        }

        $newBalance = round((float) $wallet->balance + $amount, 2);
        $wallet->update(['balance' => $newBalance]);

        WalletTransaction::query()->create([
            'wallet_id' => $wallet->id,
            'type' => $type,
            'amount' => $amount,
            'balance_after' => $newBalance,
            'description' => $description,
            'ride_id' => $ride->id,
            'reference' => 'RE-'.strtoupper(Str::random(10)),
        ]);
    }

    protected function lockWallet(int $userId): Wallet
    {
        $wallet = Wallet::query()->firstOrCreate(
            ['user_id' => $userId],
            ['balance' => 0, 'currency' => config('taxigo.currency', 'USD')],
        );

        return Wallet::query()->whereKey($wallet->id)->lockForUpdate()->firstOrFail();
    }
}
