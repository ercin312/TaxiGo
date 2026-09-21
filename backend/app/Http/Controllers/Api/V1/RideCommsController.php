<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use App\Models\Ride;
use App\Models\RideMessage;
use App\Models\User;
use App\Services\FeatureModuleService;
use App\Services\FcmPushService;
use App\Services\MaskedCallService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use RuntimeException;

class RideCommsController extends Controller
{
    /** @var array<string, string> */
    public const TEMPLATES = [
        'where_are_you' => 'Where are you?',
        'im_outside' => "I'm outside.",
        'at_the_door' => "I'm at the door / entrance.",
        'luggage' => 'I have luggage.',
        'running_late' => "I'll be 2–3 minutes late.",
        'cant_find' => "I can't find you — can you call?",
        'ok' => 'OK, got it.',
        'on_my_way' => "I'm on my way.",
    ];

    public function __construct(
        protected FeatureModuleService $modules,
        protected MaskedCallService $maskedCall,
        protected FcmPushService $fcm,
    ) {}

    public function templates(): JsonResponse
    {
        if ($this->modules->disabled('ride_comms')) {
            return response()->json(['message' => 'Ride communications module is disabled.'], 403);
        }

        $items = [];
        foreach (self::TEMPLATES as $key => $body) {
            $items[] = ['key' => $key, 'body' => $body];
        }

        return response()->json(['templates' => $items]);
    }

    public function index(Request $request, Ride $ride): JsonResponse
    {
        if ($this->modules->disabled('ride_comms')) {
            return response()->json(['message' => 'Ride communications module is disabled.'], 403);
        }

        $user = $request->user();
        if (! $this->authorizeParticipant($ride, $user)) {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        $messages = RideMessage::query()
            ->with('sender:id,name,role')
            ->where('ride_id', $ride->id)
            ->orderBy('id')
            ->limit(100)
            ->get()
            ->map(fn (RideMessage $m) => $this->serializeMessage($m, (int) $user->id));

        RideMessage::query()
            ->where('ride_id', $ride->id)
            ->where('sender_id', '!=', $user->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json([
            'messages' => $messages,
            'templates' => collect(self::TEMPLATES)
                ->map(fn ($body, $key) => ['key' => $key, 'body' => $body])
                ->values(),
            'comms_enabled' => true,
        ]);
    }

    public function store(Request $request, Ride $ride): JsonResponse
    {
        if ($this->modules->disabled('ride_comms')) {
            return response()->json(['message' => 'Ride communications module is disabled.'], 403);
        }

        $user = $request->user();
        if (! $this->authorizeParticipant($ride, $user)) {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        if (! $this->maskedCall->rideAllowsComms($ride)) {
            return response()->json(['message' => 'Messaging is only available during an active ride.'], 422);
        }

        $validated = $request->validate([
            'body' => ['required_without:template_key', 'nullable', 'string', 'max:280'],
            'template_key' => ['sometimes', 'nullable', 'string', 'max:64'],
        ]);

        $templateKey = $validated['template_key'] ?? null;
        $body = trim((string) ($validated['body'] ?? ''));

        if ($templateKey !== null && $templateKey !== '') {
            if (! isset(self::TEMPLATES[$templateKey])) {
                return response()->json(['message' => 'Unknown message template.'], 422);
            }
            $body = self::TEMPLATES[$templateKey];
        }

        if ($body === '') {
            return response()->json(['message' => 'Message body is required.'], 422);
        }

        $message = RideMessage::query()->create([
            'ride_id' => $ride->id,
            'sender_id' => $user->id,
            'body' => $body,
            'template_key' => $templateKey,
        ]);

        $message->load('sender:id,name,role');
        $this->notifyCounterpart($ride, $user, $body);

        return response()->json([
            'message' => $this->serializeMessage($message, (int) $user->id),
        ], 201);
    }

    public function maskedCall(Request $request, Ride $ride): JsonResponse
    {
        if ($this->modules->disabled('ride_comms')) {
            return response()->json(['message' => 'Ride communications module is disabled.'], 403);
        }

        $user = $request->user();
        if (! $this->authorizeParticipant($ride, $user)) {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        try {
            $session = $this->maskedCall->start($ride, $user);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        $this->notifyCallRequest($ride, $user);

        return response()->json([
            'call' => $session,
        ]);
    }

    protected function authorizeParticipant(Ride $ride, User $user): bool
    {
        if ((int) $ride->passenger_id === (int) $user->id) {
            return true;
        }

        return (bool) ($user->driver && (int) $ride->driver_id === (int) $user->driver->id);
    }

    /**
     * @return array<string, mixed>
     */
    protected function serializeMessage(RideMessage $message, int $viewerId): array
    {
        return [
            'id' => $message->id,
            'ride_id' => $message->ride_id,
            'sender_id' => $message->sender_id,
            'sender_name' => $message->sender?->name,
            'body' => $message->body,
            'template_key' => $message->template_key,
            'is_mine' => (int) $message->sender_id === $viewerId,
            'read_at' => $message->read_at?->toIso8601String(),
            'created_at' => $message->created_at?->toIso8601String(),
        ];
    }

    protected function notifyCounterpart(Ride $ride, User $sender, string $body): void
    {
        $counterpart = $this->counterpart($ride, $sender);
        if (! $counterpart) {
            return;
        }

        Notification::query()->create([
            'user_id' => $counterpart->id,
            'title' => 'New ride message',
            'body' => mb_substr($body, 0, 120),
            'type' => 'ride_message',
            'data' => [
                'ride_id' => $ride->id,
                'type' => 'ride_message',
            ],
        ]);

        if (! empty($counterpart->fcm_token) && ($counterpart->is_active_device ?? true)) {
            $this->fcm->send(
                token: $counterpart->fcm_token,
                title: 'TaxiGo',
                body: mb_substr($body, 0, 120),
                data: [
                    'type' => 'ride_message',
                    'ride_id' => (string) $ride->id,
                ],
                channelId: 'taxigo_rides',
                sound: true,
            );
        }
    }

    protected function notifyCallRequest(Ride $ride, User $initiator): void
    {
        $counterpart = $this->counterpart($ride, $initiator);
        if (! $counterpart) {
            return;
        }

        Notification::query()->create([
            'user_id' => $counterpart->id,
            'title' => 'Incoming private call',
            'body' => 'The other party started a masked call for this ride.',
            'type' => 'ride_call',
            'data' => [
                'ride_id' => $ride->id,
                'type' => 'ride_call',
            ],
        ]);

        if (! empty($counterpart->fcm_token) && ($counterpart->is_active_device ?? true)) {
            $this->fcm->send(
                token: $counterpart->fcm_token,
                title: 'Private call',
                body: 'Open the ride to connect securely.',
                data: [
                    'type' => 'ride_call',
                    'ride_id' => (string) $ride->id,
                ],
                channelId: 'taxigo_rides',
                sound: true,
            );
        }
    }

    protected function counterpart(Ride $ride, User $user): ?User
    {
        $ride->loadMissing(['passenger', 'driver.user']);

        if ((int) $ride->passenger_id === (int) $user->id) {
            return $ride->driver?->user;
        }

        if ($user->driver && (int) $ride->driver_id === (int) $user->driver->id) {
            return $ride->passenger;
        }

        return null;
    }
}
