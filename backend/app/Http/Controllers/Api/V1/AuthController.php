<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\DeviceRegistrationService;
use App\Services\FirebaseAuthService;
use App\Services\OtpAuthService;
use App\Services\SmsOtpService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;

class AuthController extends Controller
{
    public function __construct(
        protected FirebaseAuthService $firebaseAuth,
        protected OtpAuthService $otpAuth,
        protected SmsOtpService $smsOtp,
        protected DeviceRegistrationService $deviceService,
    ) {}

    /**
     * Request OTP via WhatsApp / SMS / log (TAXIGO_SMS_DRIVER).
     */
    public function requestOtp(Request $request): JsonResponse
    {
        if (app(\App\Services\FeatureModuleService::class)->disabled('otp_login')) {
            return response()->json(['message' => 'OTP login module is disabled.'], 403);
        }

        $validated = $request->validate([
            'phone' => ['required', 'string', 'min:8', 'max:20'],
            'role' => ['sometimes', 'string', 'in:passenger,driver'],
        ]);

        $phone = $this->otpAuth->normalizePhone($validated['phone']);
        $rateKey = 'otp-request:'.$phone;

        if (RateLimiter::tooManyAttempts($rateKey, 5)) {
            return response()->json([
                'message' => 'Too many OTP requests. Try again later.',
            ], 429);
        }

        RateLimiter::hit($rateKey, 60);

        $otp = $this->otpAuth->generateOtp($phone);
        $sent = $this->smsOtp->sendOtp($phone, $otp['code']);

        if (! $sent) {
            return response()->json([
                'message' => 'Failed to send verification code.',
            ], 502);
        }

        $this->otpAuth->markDelivery($phone, $this->smsOtp->channel());

        $payload = [
            'message' => 'Verification code sent.',
            'phone' => $phone,
            'channel' => $this->smsOtp->channel(),
            'expires_in' => $otp['expires_in'],
        ];

        // Dev/local convenience when using log driver.
        if (app()->environment('local') && $this->smsOtp->channel() === 'log') {
            $payload['debug_code'] = $otp['code'];
        }

        return response()->json($payload);
    }

    public function verifyOtp(Request $request): JsonResponse
    {
        if (app(\App\Services\FeatureModuleService::class)->disabled('otp_login')) {
            return response()->json(['message' => 'OTP login module is disabled.'], 403);
        }

        $validated = $request->validate([
            'phone' => ['required', 'string', 'min:8', 'max:20'],
            'code' => ['required', 'string', 'min:4', 'max:8'],
            'name' => ['sometimes', 'nullable', 'string', 'max:100'],
            'role' => ['sometimes', 'string', 'in:passenger,driver'],
            'fcm_token' => ['sometimes', 'nullable', 'string'],
            'device_id' => ['sometimes', 'nullable', 'string', 'max:64'],
            'locale' => ['sometimes', 'string', 'max:10'],
        ]);

        $phone = $this->otpAuth->normalizePhone($validated['phone']);

        if (! $this->otpAuth->verifyOtp($phone, $validated['code'])) {
            return response()->json(['message' => 'Invalid or expired code.'], 401);
        }

        $user = $this->otpAuth->findOrCreateUser(
            $phone,
            $validated['role'] ?? 'passenger',
        );

        if (! empty($validated['name'])) {
            $user->update(['name' => $validated['name']]);
            $user = $user->fresh();
        }

        if (! $user->is_active) {
            return response()->json(['message' => 'Account is deactivated.'], 403);
        }

        return $this->issueSession($user, $validated, 'whatsapp_otp');
    }

    /**
     * Temporary demo login — gated by TAXIGO_DEMO_LOGIN.
     */
    public function demoLogin(Request $request): JsonResponse
    {
        // Keep demo login available for mobile testing unless explicitly production-locked.
        $modules = app(\App\Services\FeatureModuleService::class);
        if (app()->environment('production') && $modules->disabled('demo_login')) {
            return response()->json(['message' => 'Demo login module is disabled.'], 403);
        }

        $validated = $request->validate([
            'phone' => ['required', 'string', 'min:8', 'max:20'],
            'name' => ['sometimes', 'nullable', 'string', 'max:100'],
            'role' => ['sometimes', 'string', 'in:passenger,driver'],
            'fcm_token' => ['sometimes', 'nullable', 'string'],
            'device_id' => ['sometimes', 'nullable', 'string', 'max:64'],
            'locale' => ['sometimes', 'string', 'max:10'],
        ]);

        $user = $this->otpAuth->findOrCreateUser(
            $validated['phone'],
            $validated['role'] ?? 'passenger',
        );

        if (! empty($validated['name'])) {
            $user->update(['name' => $validated['name']]);
            $user = $user->fresh();
        }

        if (! $user->is_active) {
            return response()->json(['message' => 'Account is deactivated.'], 403);
        }

        return $this->issueSession($user, $validated, 'demo');
    }

    public function firebaseVerify(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'id_token' => ['required', 'string'],
            'role' => ['sometimes', 'string', 'in:passenger,driver'],
            'fcm_token' => ['sometimes', 'nullable', 'string'],
            'device_id' => ['sometimes', 'nullable', 'string', 'max:64'],
            'locale' => ['sometimes', 'string', 'max:10'],
        ]);

        $firebaseData = $this->firebaseAuth->verifyIdToken($validated['id_token']);

        if (! $firebaseData || empty($firebaseData['firebase_uid'])) {
            return response()->json(['message' => 'Invalid Firebase ID token.'], 401);
        }

        $user = $this->firebaseAuth->findOrCreateUser(
            $firebaseData,
            $validated['role'] ?? 'passenger',
        );

        if (! $user->is_active) {
            return response()->json(['message' => 'Account is deactivated.'], 403);
        }

        return $this->issueSession($user, $validated, 'firebase');
    }

    public function logout(Request $request): JsonResponse
    {
        $user = $request->user();
        $this->deviceService->deactivateDevice($user);
        $user->currentAccessToken()?->delete();

        return response()->json(['message' => 'Logged out successfully.']);
    }

    /**
     * @param  array<string, mixed>  $validated
     */
    protected function issueSession($user, array $validated, string $authMode): JsonResponse
    {
        $this->deviceService->syncUserToken(
            $user,
            $validated['fcm_token'] ?? null,
            $validated['device_id'] ?? null,
        );

        $user->tokens()->delete();
        $token = $user->createToken('mobile-app')->plainTextToken;
        $firebaseCustomToken = $this->firebaseAuth->createCustomToken($user->fresh(['driver']));

        return response()->json([
            'token' => $token,
            'token_type' => 'Bearer',
            'user' => $user->load('driver', 'wallet'),
            'auth_mode' => $authMode,
            'firebase_custom_token' => $firebaseCustomToken,
        ]);
    }
}
