<?php

namespace App\Services;

use App\Enums\RideStatus;
use App\Models\Ride;
use App\Models\RideCallSession;
use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use RuntimeException;

/**
 * Privacy-preserving voice bridge for active rides.
 * Drivers: stub (proxy number / in-app notify) | twilio (Proxy session).
 */
class MaskedCallService
{
    public function driver(): string
    {
        return (string) config('taxigo.comms.masked_call.driver', 'stub');
    }

    /**
     * @return array{session_ref: string, dial_number: string|null, display_label: string, provider: string, expires_at: string|null, instructions: string}
     */
    public function start(Ride $ride, User $initiator): array
    {
        if (app(FeatureModuleService::class)->disabled('ride_comms')) {
            throw new RuntimeException('Ride communications module is disabled.');
        }

        if (! $this->rideAllowsComms($ride)) {
            throw new RuntimeException('Calls are only available during an active ride.');
        }

        return match ($this->driver()) {
            'twilio' => $this->startTwilio($ride, $initiator),
            default => $this->startStub($ride, $initiator),
        };
    }

    public function rideAllowsComms(Ride $ride): bool
    {
        $status = $ride->status instanceof RideStatus
            ? $ride->status
            : RideStatus::tryFrom((string) $ride->status);

        if (! $status || $status->isTerminal()) {
            return false;
        }

        return in_array($status, [
            RideStatus::DriverAssigned,
            RideStatus::DriverArriving,
            RideStatus::DriverArrived,
            RideStatus::PassengerOnBoard,
            RideStatus::InProgress,
        ], true);
    }

    /**
     * @return array{session_ref: string, dial_number: string|null, display_label: string, provider: string, expires_at: string|null, instructions: string}
     */
    protected function startStub(Ride $ride, User $initiator): array
    {
        $proxy = (string) config('taxigo.comms.masked_call.proxy_number', '');
        $sessionRef = 'CALL-'.strtoupper(Str::random(10));
        $expiresAt = now()->addMinutes(30);

        $session = RideCallSession::query()->create([
            'ride_id' => $ride->id,
            'initiator_id' => $initiator->id,
            'provider' => 'stub',
            'proxy_number' => $proxy !== '' ? $proxy : null,
            'session_ref' => $sessionRef,
            'status' => 'created',
            'meta' => [
                'mode' => $proxy !== '' ? 'proxy_dial' : 'notify_only',
            ],
            'expires_at' => $expiresAt,
        ]);

        Log::info('Masked call stub session', [
            'ride_id' => $ride->id,
            'session' => $sessionRef,
            'has_proxy' => $proxy !== '',
        ]);

        return [
            'session_ref' => $session->session_ref,
            'dial_number' => $proxy !== '' ? $proxy : null,
            'display_label' => 'Private number',
            'provider' => 'stub',
            'expires_at' => $expiresAt->toIso8601String(),
            'instructions' => $proxy !== ''
                ? 'Dial the private number. Your real phone number stays hidden.'
                : 'Call request sent. The other party is notified without sharing numbers.',
        ];
    }

    /**
     * @return array{session_ref: string, dial_number: string|null, display_label: string, provider: string, expires_at: string|null, instructions: string}
     */
    protected function startTwilio(Ride $ride, User $initiator): array
    {
        $sid = (string) config('taxigo.comms.masked_call.twilio.account_sid');
        $token = (string) config('taxigo.comms.masked_call.twilio.auth_token');
        $proxyService = (string) config('taxigo.comms.masked_call.twilio.proxy_service_sid');
        $proxyNumber = (string) config('taxigo.comms.masked_call.twilio.proxy_number');

        if ($sid === '' || $token === '' || $proxyService === '' || $proxyNumber === '') {
            throw new RuntimeException('Twilio masked calling is not configured.');
        }

        $counterpart = $this->counterpartPhone($ride, $initiator);
        if ($counterpart === null || $counterpart === '') {
            throw new RuntimeException('Counterpart phone number is missing.');
        }

        $initiatorPhone = (string) ($initiator->phone ?? '');
        if ($initiatorPhone === '') {
            throw new RuntimeException('Your phone number is required for masked calling.');
        }

        $sessionRef = 'CALL-'.strtoupper(Str::random(10));
        $expiresAt = now()->addMinutes(45);

        try {
            $response = Http::withBasicAuth($sid, $token)
                ->asForm()
                ->timeout(20)
                ->post(
                    "https://proxy.twilio.com/v1/Services/{$proxyService}/Sessions",
                    [
                        'UniqueName' => $sessionRef,
                        'Mode' => 'voice-only',
                        'Ttl' => 2700,
                    ],
                );

            $body = $response->json() ?? [];
            if (! $response->successful()) {
                throw new RuntimeException(
                    (string) ($body['message'] ?? 'Twilio proxy session failed')
                );
            }

            $twilioSessionSid = (string) ($body['sid'] ?? '');

            RideCallSession::query()->create([
                'ride_id' => $ride->id,
                'initiator_id' => $initiator->id,
                'provider' => 'twilio',
                'proxy_number' => $proxyNumber,
                'session_ref' => $sessionRef,
                'status' => 'created',
                'meta' => [
                    'twilio_session_sid' => $twilioSessionSid,
                    'counterpart_masked' => true,
                ],
                'expires_at' => $expiresAt,
            ]);

            return [
                'session_ref' => $sessionRef,
                'dial_number' => $proxyNumber,
                'display_label' => 'Private number',
                'provider' => 'twilio',
                'expires_at' => $expiresAt->toIso8601String(),
                'instructions' => 'Dial the private number. TaxiGo connects you without sharing real numbers.',
            ];
        } catch (RuntimeException $e) {
            throw $e;
        } catch (\Throwable $e) {
            Log::error('Twilio masked call error', ['message' => $e->getMessage()]);
            throw new RuntimeException('Masked call provider error.');
        }
    }

    protected function counterpartPhone(Ride $ride, User $initiator): ?string
    {
        $ride->loadMissing(['passenger', 'driver.user']);

        if ((int) $ride->passenger_id === (int) $initiator->id) {
            return $ride->driver?->user?->phone;
        }

        if ($initiator->driver && (int) $ride->driver_id === (int) $initiator->driver->id) {
            return $ride->passenger?->phone;
        }

        return null;
    }
}
