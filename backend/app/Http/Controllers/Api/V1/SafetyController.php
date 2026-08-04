<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Complaint;
use App\Models\Notification;
use App\Models\Ride;
use App\Models\User;
use App\Enums\UserRole;
use App\Services\FcmPushService;
use App\Services\FeatureModuleService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class SafetyController extends Controller
{
    public function __construct(
        protected FcmPushService $fcmPush,
    ) {}

    public function sos(Request $request): JsonResponse
    {
        if (app(FeatureModuleService::class)->disabled('sos_alerts')) {
            return response()->json(['message' => 'SOS module is disabled.'], 403);
        }

        $validated = $request->validate([
            'ride_id' => ['sometimes', 'nullable', 'exists:rides,id'],
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'message' => ['sometimes', 'nullable', 'string', 'max:500'],
        ]);

        $user = $request->user();
        $reference = 'SOS-'.strtoupper(Str::random(8));

        $complaint = Complaint::query()->create([
            'user_id' => $user->id,
            'ride_id' => $validated['ride_id'] ?? null,
            'subject' => 'SOS Emergency Alert',
            'description' => $validated['message'] ?? 'Emergency SOS triggered by user.',
            'status' => 'urgent',
            'latitude' => $validated['latitude'],
            'longitude' => $validated['longitude'],
            'metadata' => [
                'reference' => $reference,
                'user_phone' => $user->phone,
                'user_name' => $user->name,
            ],
        ]);

        Notification::query()->create([
            'user_id' => $user->id,
            'title' => 'SOS Alert Sent',
            'body' => 'Your emergency alert has been received. Help is on the way.',
            'type' => 'sos',
            'data' => [
                'complaint_id' => $complaint->id,
                'reference' => $reference,
                'latitude' => $validated['latitude'],
                'longitude' => $validated['longitude'],
            ],
        ]);

        $notified = $this->notifyOps($complaint, $user, $validated, $reference);

        return response()->json([
            'message' => 'SOS alert sent successfully.',
            'complaint_id' => $complaint->id,
            'reference' => $reference,
            'notified' => $notified,
        ], 201);
    }

    public function shareTrip(Request $request, Ride $ride): JsonResponse
    {
        if (app(FeatureModuleService::class)->disabled('share_trip')) {
            return response()->json(['message' => 'Share trip module is disabled.'], 403);
        }

        $user = $request->user();
        $isPassenger = $ride->passenger_id === $user->id;
        $isDriver = $user->driver && $ride->driver_id === $user->driver->id;

        if (! $isPassenger && ! $isDriver) {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        $shareToken = $ride->share_token;
        if (empty($shareToken) || ($ride->share_expires_at && $ride->share_expires_at->isPast())) {
            $shareToken = hash('sha256', Str::random(40).$ride->id.config('app.key'));
            $ride->update([
                'share_token' => $shareToken,
                'share_expires_at' => now()->addHours(24),
            ]);
        }

        $shareUrl = url("/shared/trip/{$ride->reference}?token={$shareToken}");

        return response()->json([
            'share_url' => $shareUrl,
            'ride' => [
                'reference' => $ride->reference,
                'status' => $ride->status->value,
                'pickup_address' => $ride->pickup_address,
                'dropoff_address' => $ride->dropoff_address,
                'driver' => $ride->driver?->load('user', 'vehicle'),
            ],
            'expires_at' => $ride->fresh()->share_expires_at?->toIso8601String(),
        ]);
    }

    /**
     * @param  array<string, mixed>  $validated
     * @return array{admins: int, driver: bool, webhook: bool}
     */
    protected function notifyOps(
        Complaint $complaint,
        User $user,
        array $validated,
        string $reference,
    ): array {
        $title = 'SOS Emergency';
        $body = sprintf(
            '%s · %s (%.5f, %.5f)',
            $user->name ?? 'User',
            $reference,
            $validated['latitude'],
            $validated['longitude'],
        );

        $adminCount = 0;
        if (config('taxigo.sos.notify_admins', true)) {
            $admins = User::query()
                ->where('role', UserRole::Admin)
                ->whereNotNull('fcm_token')
                ->get();

            foreach ($admins as $admin) {
                if ($this->fcmPush->send(
                    token: (string) $admin->fcm_token,
                    title: $title,
                    body: $body,
                    data: [
                        'type' => 'sos',
                        'complaint_id' => (string) $complaint->id,
                        'reference' => $reference,
                        'latitude' => (string) $validated['latitude'],
                        'longitude' => (string) $validated['longitude'],
                    ],
                    channelId: 'taxigo_sos',
                    sound: true,
                )) {
                    $adminCount++;
                }
            }
        }

        $driverNotified = false;
        if (! empty($validated['ride_id'])) {
            $ride = Ride::query()->with('driver.user')->find($validated['ride_id']);
            $driverToken = $ride?->driver?->user?->fcm_token;
            if ($driverToken) {
                $driverNotified = $this->fcmPush->send(
                    token: $driverToken,
                    title: $title,
                    body: 'Passenger triggered SOS during the trip.',
                    data: [
                        'type' => 'sos',
                        'ride_id' => (string) $validated['ride_id'],
                        'reference' => $reference,
                    ],
                    channelId: 'taxigo_sos',
                    sound: true,
                );
            }
        }

        $webhook = false;
        $webhookUrl = config('taxigo.sos.webhook_url');
        if (! empty($webhookUrl)) {
            try {
                $response = Http::timeout(10)->post($webhookUrl, [
                    'type' => 'sos',
                    'reference' => $reference,
                    'complaint_id' => $complaint->id,
                    'user_id' => $user->id,
                    'phone' => $user->phone,
                    'latitude' => $validated['latitude'],
                    'longitude' => $validated['longitude'],
                    'message' => $validated['message'] ?? null,
                    'ride_id' => $validated['ride_id'] ?? null,
                ]);
                $webhook = $response->successful();
            } catch (\Throwable $e) {
                Log::warning('SOS webhook failed', ['error' => $e->getMessage()]);
            }
        }

        Log::critical('SOS alert', [
            'reference' => $reference,
            'complaint_id' => $complaint->id,
            'user_id' => $user->id,
            'latitude' => $validated['latitude'],
            'longitude' => $validated['longitude'],
        ]);

        return [
            'admins' => $adminCount,
            'driver' => $driverNotified,
            'webhook' => $webhook,
        ];
    }
}
