<?php

namespace App\Services;

use App\Models\DeviceRegistration;
use App\Models\User;

class DeviceRegistrationService
{
    public function register(
        string $deviceId,
        string $fcmToken,
        string $platform = 'android',
        ?string $phone = null,
    ): DeviceRegistration {
        $phone = $phone ? app(OtpAuthService::class)->normalizePhone($phone) : null;

        return DeviceRegistration::query()->updateOrCreate(
            ['device_id' => $deviceId],
            [
                'fcm_token' => $fcmToken,
                'platform' => $platform,
                'phone' => $phone,
                'is_active' => true,
                'last_seen_at' => now(),
            ],
        );
    }

    public function resolveFcmToken(
        string $phone,
        ?string $requestToken = null,
        ?string $deviceId = null,
        ?string $platform = null,
    ): ?string {
        if ($requestToken) {
            $resolvedDeviceId = $deviceId ?? hash('sha256', $requestToken);

            $this->register(
                deviceId: $resolvedDeviceId,
                fcmToken: $requestToken,
                platform: $platform ?? 'android',
                phone: $phone,
            );

            return $requestToken;
        }

        $device = null;

        if ($deviceId) {
            $device = DeviceRegistration::query()
                ->where('device_id', $deviceId)
                ->where('is_active', true)
                ->whereNotNull('fcm_token')
                ->first();
        }

        if ($device?->fcm_token) {
            return $device->fcm_token;
        }

        $user = User::query()
            ->where('phone', $phone)
            ->where('is_active_device', true)
            ->whereNotNull('fcm_token')
            ->first();

        return $user?->fcm_token;
    }

    public function syncUserToken(User $user, ?string $fcmToken, ?string $deviceId = null): void
    {
        if (empty($fcmToken)) {
            return;
        }

        $user->update([
            'fcm_token' => $fcmToken,
            'fcm_token_updated_at' => now(),
            'is_active_device' => true,
        ]);

        if ($deviceId) {
            DeviceRegistration::query()
                ->where('device_id', $deviceId)
                ->update([
                    'phone' => $user->phone,
                    'fcm_token' => $fcmToken,
                    'is_active' => true,
                    'last_seen_at' => now(),
                ]);
        }
    }

    public function deactivateDevice(User $user): void
    {
        $user->update([
            'is_active_device' => false,
            'fcm_token' => null,
        ]);
    }
}
