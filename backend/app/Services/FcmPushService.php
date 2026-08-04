<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FcmPushService
{
    public function isConfigured(): bool
    {
        $projectId = config('taxigo.firebase.project_id');
        $credentials = config('taxigo.firebase.credentials');

        if (empty($credentials)) {
            return false;
        }

        $path = $this->resolveCredentialsPath($credentials);

        return ! empty($projectId) && is_readable($path);
    }

    public function sendOtp(string $fcmToken, string $code): bool
    {
        $title = config('taxigo.otp.push_title', 'TaxiGo Verification');
        $body = str_replace(':code', $code, config('taxigo.otp.push_body', 'Your login code: :code'));

        return $this->send(
            token: $fcmToken,
            title: $title,
            body: $body,
            data: [
                'type' => 'otp',
                'code' => $code,
                'expires_in' => (string) config('taxigo.otp.ttl_seconds', 300),
            ],
            channelId: 'taxigo_otp',
            sound: true,
        );
    }

    /**
     * @param  array<string, string>  $data
     */
    public function sendRideRequest(
        string $fcmToken,
        int $rideId,
        string $pickupAddress,
        string $offeredFare,
    ): bool {
        return $this->send(
            token: $fcmToken,
            title: 'Yeni yolculuk isteği',
            body: "{$pickupAddress} — {$offeredFare}",
            data: [
                'type' => 'ride_request',
                'ride_id' => (string) $rideId,
                'pickup_address' => $pickupAddress,
                'offered_fare' => $offeredFare,
            ],
            channelId: 'taxigo_rides',
            sound: true,
        );
    }

    /**
     * @param  array<string, string>  $data
     */
    public function send(
        string $token,
        string $title,
        string $body,
        array $data = [],
        string $channelId = 'taxigo_rides',
        bool $sound = true,
    ): bool {
        if (! $this->isConfigured()) {
            return false;
        }

        $accessToken = $this->getAccessToken();
        if ($accessToken === null) {
            return false;
        }

        $projectId = config('taxigo.firebase.project_id');
        $stringData = [];
        foreach ($data as $key => $value) {
            $stringData[(string) $key] = (string) $value;
        }

        $payload = [
            'message' => [
                'token' => $token,
                'notification' => [
                    'title' => $title,
                    'body' => $body,
                ],
                'data' => $stringData,
                'android' => [
                    'priority' => 'high',
                    'notification' => [
                        'channel_id' => $channelId,
                        'sound' => $sound ? 'default' : null,
                        'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    ],
                ],
                'apns' => [
                    'headers' => ['apns-priority' => '10'],
                    'payload' => [
                        'aps' => [
                            'alert' => [
                                'title' => $title,
                                'body' => $body,
                            ],
                            'sound' => $sound ? 'default' : null,
                            'content-available' => 1,
                        ],
                    ],
                ],
            ],
        ];

        $response = Http::timeout(15)
            ->withToken($accessToken)
            ->post("https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send", $payload);

        if ($response->failed()) {
            Log::warning('FCM send failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return false;
        }

        return true;
    }

    protected function resolveCredentialsPath(string $credentials): string
    {
        if (is_readable($credentials)) {
            return $credentials;
        }

        $absolute = base_path($credentials);
        if (is_readable($absolute)) {
            return $absolute;
        }

        return $credentials;
    }

    protected function getAccessToken(): ?string
    {
        return Cache::remember('taxigo_fcm_access_token', 3300, function () {
            $credentialsPath = $this->resolveCredentialsPath(
                (string) config('taxigo.firebase.credentials')
            );

            if (! is_readable($credentialsPath)) {
                return null;
            }

            $credentials = json_decode((string) file_get_contents($credentialsPath), true);
            if (! is_array($credentials)) {
                return null;
            }

            $clientEmail = $credentials['client_email'] ?? null;
            $privateKey = $credentials['private_key'] ?? null;
            if (! $clientEmail || ! $privateKey) {
                return null;
            }

            $now = time();
            $jwt = $this->createJwt([
                'iss' => $clientEmail,
                'sub' => $clientEmail,
                'aud' => 'https://oauth2.googleapis.com/token',
                'iat' => $now,
                'exp' => $now + 3600,
                'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
            ], $privateKey);

            $tokenResponse = Http::asForm()->post('https://oauth2.googleapis.com/token', [
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt,
            ]);

            if ($tokenResponse->failed()) {
                Log::warning('FCM access token request failed', [
                    'body' => $tokenResponse->body(),
                ]);

                return null;
            }

            return $tokenResponse->json('access_token');
        });
    }

    /**
     * @param  array<string, mixed>  $claims
     */
    protected function createJwt(array $claims, string $privateKey): string
    {
        $header = $this->base64UrlEncode(json_encode([
            'alg' => 'RS256',
            'typ' => 'JWT',
        ]));
        $payload = $this->base64UrlEncode(json_encode($claims));
        $input = "{$header}.{$payload}";
        openssl_sign($input, $signature, $privateKey, OPENSSL_ALGO_SHA256);

        return "{$input}.".$this->base64UrlEncode($signature);
    }

    protected function base64UrlEncode(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }
}
