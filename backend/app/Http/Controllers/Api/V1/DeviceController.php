<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\DeviceRegistrationService;
use App\Services\OtpAuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DeviceController extends Controller
{
    public function __construct(
        protected DeviceRegistrationService $deviceService,
        protected OtpAuthService $otpAuth,
    ) {}

    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'device_id' => ['required', 'string', 'max:64'],
            'fcm_token' => ['required', 'string', 'max:512'],
            'platform' => ['sometimes', 'string', 'in:android,ios'],
            'phone' => ['sometimes', 'nullable', 'string', 'max:20'],
        ]);

        $phone = isset($validated['phone'])
            ? $this->otpAuth->normalizePhone($validated['phone'])
            : null;

        $device = $this->deviceService->register(
            deviceId: $validated['device_id'],
            fcmToken: $validated['fcm_token'],
            platform: $validated['platform'] ?? 'android',
            phone: $phone,
        );

        return response()->json([
            'message' => 'Device registered.',
            'device' => [
                'device_id' => $device->device_id,
                'platform' => $device->platform,
                'last_seen_at' => $device->last_seen_at,
            ],
        ]);
    }
}
