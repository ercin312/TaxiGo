<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Str;

class OtpAuthService
{
    public function normalizePhone(string $phone): string
    {
        $digits = preg_replace('/[^\d+]/', '', $phone) ?? '';

        if (! str_starts_with($digits, '+')) {
            if (str_starts_with($digits, '0')) {
                $digits = '+90'.substr($digits, 1);
            } elseif (str_starts_with($digits, '90')) {
                $digits = '+'.$digits;
            } else {
                $digits = '+'.$digits;
            }
        }

        return $digits;
    }

    /**
     * @return array{expires_in: int, code: string}
     */
    public function generateOtp(string $phone): array
    {
        $phone = $this->normalizePhone($phone);
        $length = (int) config('taxigo.otp.length', 6);
        $ttl = (int) config('taxigo.otp.ttl_seconds', 300);
        $max = (10 ** $length) - 1;

        $code = str_pad((string) random_int(0, $max), $length, '0', STR_PAD_LEFT);

        Cache::put($this->cacheKey($phone), [
            'code' => $code,
            'attempts' => 0,
            'delivery' => null,
        ], now()->addSeconds($ttl));

        return [
            'expires_in' => $ttl,
            'code' => $code,
        ];
    }

    public function markDelivery(string $phone, string $delivery): void
    {
        $phone = $this->normalizePhone($phone);
        $key = $this->cacheKey($phone);
        $data = Cache::get($key);

        if (! is_array($data)) {
            return;
        }

        $data['delivery'] = $delivery;
        $ttl = (int) config('taxigo.otp.ttl_seconds', 300);
        Cache::put($key, $data, now()->addSeconds($ttl));
    }

    public function verifyOtp(string $phone, string $code): bool
    {
        $phone = $this->normalizePhone($phone);
        $key = $this->cacheKey($phone);
        $cached = Cache::get($key);

        if (! is_array($cached) || ! isset($cached['code'])) {
            return false;
        }

        $attempts = (int) ($cached['attempts'] ?? 0);

        if ($attempts >= (int) config('taxigo.otp.max_attempts', 5)) {
            Cache::forget($key);

            return false;
        }

        if (! hash_equals((string) $cached['code'], trim($code))) {
            $cached['attempts'] = $attempts + 1;
            $ttl = (int) config('taxigo.otp.ttl_seconds', 300);
            Cache::put($key, $cached, now()->addSeconds($ttl));

            return false;
        }

        Cache::forget($key);

        return true;
    }

    public function findOrCreateUser(string $phone, string $role = 'passenger'): User
    {
        $phone = $this->normalizePhone($phone);
        $userRole = \App\Enums\UserRole::tryFrom($role) ?? \App\Enums\UserRole::Passenger;

        $user = User::query()->where('phone', $phone)->first();

        if ($user) {
            $user->update(array_filter([
                'locale' => request()->input('locale', $user->locale),
            ]));

            app(DeviceRegistrationService::class)->syncUserToken(
                $user,
                request()->input('fcm_token'),
                request()->input('device_id'),
            );

            return $user->fresh();
        }

        $user = User::query()->create([
            'name' => 'User '.Str::random(6),
            'phone' => $phone,
            'role' => $userRole,
            'locale' => request()->input('locale', config('taxigo.default_locale', 'en')),
            'is_active' => true,
            'is_active_device' => true,
        ]);

        app(DeviceRegistrationService::class)->syncUserToken(
            $user,
            request()->input('fcm_token'),
            request()->input('device_id'),
        );

        return $user->fresh();
    }

    protected function cacheKey(string $phone): string
    {
        return 'taxigo_otp:'.hash('sha256', $phone);
    }
}
