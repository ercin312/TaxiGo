<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class FirebaseAuthService
{
    public function verifyIdToken(string $idToken): ?array
    {
        $apiKey = config('taxigo.firebase.api_key');

        if (empty($apiKey)) {
            return null;
        }

        $response = Http::timeout(10)->post(
            'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key='.$apiKey,
            ['idToken' => $idToken],
        );

        if (! $response->successful()) {
            return null;
        }

        $users = $response->json('users', []);

        if (empty($users)) {
            return null;
        }

        $firebaseUser = $users[0];

        return [
            'firebase_uid' => $firebaseUser['localId'] ?? null,
            'email' => $firebaseUser['email'] ?? null,
            'phone' => $firebaseUser['phoneNumber'] ?? null,
            'name' => $firebaseUser['displayName'] ?? null,
            'avatar' => $firebaseUser['photoUrl'] ?? null,
            'email_verified' => ($firebaseUser['emailVerified'] ?? 'false') === 'true',
        ];
    }

    public function findOrCreateUser(array $firebaseData, string $role = 'passenger'): User
    {
        $user = User::query()
            ->where('firebase_uid', $firebaseData['firebase_uid'])
            ->first();

        if (! $user && ! empty($firebaseData['email'])) {
            $user = User::query()
                ->where('email', $firebaseData['email'])
                ->first();
        }

        if ($user) {
            $user->update(array_filter([
                'firebase_uid' => $firebaseData['firebase_uid'] ?? $user->firebase_uid,
                'name' => $firebaseData['name'] ?? $user->name,
                'email' => $firebaseData['email'] ?? $user->email,
                'phone' => $firebaseData['phone'] ?? $user->phone,
                'avatar' => $firebaseData['avatar'] ?? $user->avatar,
                'fcm_token' => request()->input('fcm_token', $user->fcm_token),
            ]));

            return $user->fresh();
        }

        return User::query()->create([
            'firebase_uid' => $firebaseData['firebase_uid'],
            'name' => $firebaseData['name'] ?? 'User '.Str::random(6),
            'email' => $firebaseData['email'],
            'phone' => $firebaseData['phone'],
            'avatar' => $firebaseData['avatar'],
            'role' => $role,
            'locale' => request()->input('locale', config('taxigo.default_locale', 'en')),
            'is_active' => true,
            'fcm_token' => request()->input('fcm_token'),
        ]);
    }

    /**
     * Mint a Firebase custom token so the mobile client can sign in for RTDB.
     * Driver UID = "{driverId}" to match drivers/{driverId} security rules.
     * Passenger UID = "u{userId}".
     */
    public function createCustomToken(User $user): ?string
    {
        $credentials = $this->loadServiceAccount();
        if ($credentials === null) {
            return null;
        }

        $user->loadMissing('driver');
        $uid = $user->driver
            ? (string) $user->driver->id
            : 'u'.$user->id;

        if (empty($user->firebase_uid) || $user->firebase_uid !== $uid) {
            $user->forceFill(['firebase_uid' => $uid])->save();
        }

        $now = time();
        $claims = [
            'iss' => $credentials['client_email'],
            'sub' => $credentials['client_email'],
            'aud' => 'https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit',
            'iat' => $now,
            'exp' => $now + 3600,
            'uid' => $uid,
            'claims' => [
                'taxigo_user_id' => $user->id,
                'role' => $user->role?->value ?? (string) $user->role,
                'driver_id' => $user->driver?->id,
            ],
        ];

        try {
            return $this->encodeJwt($claims, $credentials['private_key']);
        } catch (\Throwable $e) {
            Log::warning('Firebase custom token failed', ['error' => $e->getMessage()]);

            return null;
        }
    }

    /**
     * @return array{client_email: string, private_key: string}|null
     */
    protected function loadServiceAccount(): ?array
    {
        $path = config('taxigo.firebase.credentials');
        if (empty($path)) {
            return null;
        }

        if (! str_starts_with($path, '/') && ! preg_match('/^[A-Za-z]:/', $path)) {
            $path = base_path($path);
            if (! is_readable($path)) {
                $path = storage_path('app/'.ltrim((string) config('taxigo.firebase.credentials'), '/'));
            }
        }

        if (! is_readable($path)) {
            return null;
        }

        $json = json_decode((string) file_get_contents($path), true);
        if (! is_array($json) || empty($json['client_email']) || empty($json['private_key'])) {
            return null;
        }

        return [
            'client_email' => $json['client_email'],
            'private_key' => $json['private_key'],
        ];
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    protected function encodeJwt(array $payload, string $privateKey): string
    {
        $header = ['alg' => 'RS256', 'typ' => 'JWT'];
        $segments = [
            $this->base64UrlEncode(json_encode($header, JSON_THROW_ON_ERROR)),
            $this->base64UrlEncode(json_encode($payload, JSON_THROW_ON_ERROR)),
        ];
        $signingInput = implode('.', $segments);

        $key = openssl_pkey_get_private($privateKey);
        if ($key === false) {
            throw new \RuntimeException('Invalid Firebase private key.');
        }

        $signature = '';
        $ok = openssl_sign($signingInput, $signature, $key, OPENSSL_ALGO_SHA256);
        if (! $ok) {
            throw new \RuntimeException('Unable to sign Firebase custom token.');
        }

        $segments[] = $this->base64UrlEncode($signature);

        return implode('.', $segments);
    }

    protected function base64UrlEncode(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }
}
