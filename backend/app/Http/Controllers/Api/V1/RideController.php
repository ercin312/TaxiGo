<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\PaymentMethod;
use App\Enums\RideStatus;
use App\Exceptions\InvalidRideTransitionException;
use App\Http\Controllers\Controller;
use App\Models\PromoCode;
use App\Models\Ride;
use App\Services\FareCalculatorService;
use App\Services\FeatureModuleService;
use App\Services\FirebaseRtdbService;
use App\Services\GoogleMapsService;
use App\Services\RideDispatchService;
use App\Services\RideMatchingService;
use App\Services\RideStatusService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class RideController extends Controller
{
    public function __construct(
        protected FareCalculatorService $fareCalculator,
        protected GoogleMapsService $mapsService,
        protected RideStatusService $statusService,
        protected RideMatchingService $matchingService,
        protected FirebaseRtdbService $rtdbService,
        protected RideDispatchService $dispatchService,
    ) {}

    public function eta(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'pickup_latitude' => ['required', 'numeric', 'between:-90,90'],
            'pickup_longitude' => ['required', 'numeric', 'between:-180,180'],
            'dropoff_latitude' => ['required', 'numeric', 'between:-90,90'],
            'dropoff_longitude' => ['required', 'numeric', 'between:-180,180'],
            'vehicle_type' => ['sometimes', 'string', 'max:50'],
            'promo_code' => ['sometimes', 'nullable', 'string'],
        ]);

        [$distance, $duration, $routeSource] = $this->resolveRouteMetrics($validated);

        $promoCode = null;
        if (! empty($validated['promo_code'])) {
            $promoCode = PromoCode::query()
                ->where('code', strtoupper($validated['promo_code']))
                ->first();
        }

        $fare = $this->fareCalculator->calculate(
            $distance,
            $duration,
            $validated['vehicle_type'] ?? 'standard',
            $promoCode,
        );

        $nearbyDrivers = $this->matchingService->findNearbyDrivers(
            $validated['pickup_latitude'],
            $validated['pickup_longitude'],
            config('taxigo.matching.radius_km'),
            config('taxigo.matching.max_drivers'),
            $validated['vehicle_type'] ?? 'standard',
        );

        return response()->json([
            'distance_km' => $distance,
            'estimated_duration_minutes' => $duration,
            'route_source' => $routeSource,
            'fare' => $fare,
            'nearby_drivers_count' => $nearbyDrivers->count(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'pickup_latitude' => ['required', 'numeric', 'between:-90,90'],
            'pickup_longitude' => ['required', 'numeric', 'between:-180,180'],
            'pickup_address' => ['required', 'string', 'max:500'],
            'dropoff_latitude' => ['required', 'numeric', 'between:-90,90'],
            'dropoff_longitude' => ['required', 'numeric', 'between:-180,180'],
            'dropoff_address' => ['required', 'string', 'max:500'],
            'payment_method' => ['sometimes', Rule::enum(PaymentMethod::class)],
            'vehicle_type' => ['sometimes', 'string', 'max:50'],
            'promo_code' => ['sometimes', 'nullable', 'string'],
            'offered_fare' => ['sometimes', 'numeric', 'min:0'],
        ]);

        $paymentMethod = PaymentMethod::tryFrom(
            (string) ($validated['payment_method'] ?? PaymentMethod::Cash->value)
        ) ?? PaymentMethod::Cash;

        if ($paymentMethod === PaymentMethod::Card
            && app(FeatureModuleService::class)->disabled('card_payments')) {
            return response()->json([
                'message' => 'Card payments module is disabled.',
            ], 403);
        }

        [$distance, $duration] = $this->resolveRouteMetrics($validated);

        $promoCode = null;
        if (! empty($validated['promo_code'])) {
            $promoCode = PromoCode::query()
                ->where('code', strtoupper($validated['promo_code']))
                ->first();

            if (! $promoCode || ! $promoCode->isValid()) {
                return response()->json(['message' => 'Invalid or expired promo code.'], 422);
            }
        }

        $fare = $this->fareCalculator->calculate(
            $distance,
            $duration,
            $validated['vehicle_type'] ?? 'standard',
            $promoCode,
        );

        $offeredFare = isset($validated['offered_fare'])
            ? (float) $validated['offered_fare']
            : (float) $fare['fare'];

        if ($offeredFare < (float) $fare['fare']) {
            return response()->json([
                'message' => 'Offered fare cannot be below the minimum fare.',
                'minimum_fare' => $fare['fare'],
            ], 422);
        }

        $ride = Ride::query()->create([
            'reference' => 'TG-'.strtoupper(Str::random(10)),
            'passenger_id' => $request->user()->id,
            'status' => RideStatus::Pending,
            'pickup_latitude' => $validated['pickup_latitude'],
            'pickup_longitude' => $validated['pickup_longitude'],
            'pickup_address' => $validated['pickup_address'],
            'dropoff_latitude' => $validated['dropoff_latitude'],
            'dropoff_longitude' => $validated['dropoff_longitude'],
            'dropoff_address' => $validated['dropoff_address'],
            'estimated_distance_km' => $distance,
            'estimated_duration_minutes' => $duration,
            'estimated_fare' => $offeredFare,
            'offered_fare' => $offeredFare,
            'minimum_fare' => $fare['fare'],
            'is_bidding' => app(FeatureModuleService::class)->enabled('bidding'),
            'payment_method' => $paymentMethod,
            'payment_status' => \App\Enums\PaymentStatus::Pending,
            'payment_provider' => $paymentMethod === PaymentMethod::Card
                ? app(\App\Services\CardPaymentService::class)->driver()
                : null,
            'promo_code_id' => $promoCode?->id,
            'discount_amount' => $fare['discount'],
            'commission_amount' => $fare['commission'],
            'expires_at' => now()->addMinutes(config('taxigo.ride_expiry_minutes', 15)),
        ]);

        $this->rtdbService->syncRide($ride);

        $notified = $this->dispatchService->notifyNearbyDrivers(
            $ride,
            $validated['vehicle_type'] ?? 'standard',
        );

        return response()->json([
            'message' => 'Ride requested successfully.',
            'ride' => $ride->load('passenger', 'driver.user'),
            'notified_drivers' => $notified,
        ], 201);
    }

    public function show(Request $request, Ride $ride): JsonResponse
    {
        $this->authorizeRideAccess($request, $ride);

        return response()->json([
            'ride' => $ride->load('passenger', 'driver.user', 'driver.vehicle', 'locations', 'rating'),
        ]);
    }

    public function cancel(Request $request, Ride $ride): JsonResponse
    {
        $this->authorizeRideAccess($request, $ride);

        $validated = $request->validate([
            'reason' => ['sometimes', 'nullable', 'string', 'max:500'],
        ]);

        if ($ride->status->isTerminal()) {
            return response()->json(['message' => 'Ride cannot be cancelled.'], 422);
        }

        try {
            $ride = $this->statusService->transition($ride, RideStatus::CancelledByPassenger, [
                'cancellation_reason' => $validated['reason'] ?? null,
            ]);
        } catch (InvalidRideTransitionException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        $this->rtdbService->syncRide($ride);

        return response()->json([
            'message' => 'Ride cancelled successfully.',
            'ride' => $ride,
        ]);
    }

    public function history(Request $request): JsonResponse
    {
        $rides = $request->user()
            ->passengerRides()
            ->with(['driver.user', 'driver.vehicle', 'rating'])
            ->latest()
            ->paginate($request->integer('per_page', 15));

        return response()->json($rides);
    }

    public function active(Request $request): JsonResponse
    {
        $ride = $request->user()
            ->passengerRides()
            ->whereNotIn('status', [
                RideStatus::Completed,
                RideStatus::CancelledByPassenger,
                RideStatus::CancelledByDriver,
                RideStatus::Expired,
            ])
            ->latest()
            ->with(['driver.user', 'driver.vehicle'])
            ->first();

        return response()->json(['ride' => $ride]);
    }

    protected function authorizeRideAccess(Request $request, Ride $ride): void
    {
        $user = $request->user();
        $isPassenger = $ride->passenger_id === $user->id;
        $isDriver = $user->driver && $ride->driver_id === $user->driver->id;

        if (! $isPassenger && ! $isDriver && ! $user->isAdmin()) {
            abort(403, 'Unauthorized access to this ride.');
        }
    }

    /**
     * @param  array<string, mixed>  $validated
     * @return array{0: float, 1: int, 2: string}
     */
    protected function resolveRouteMetrics(array $validated): array
    {
        if (app(FeatureModuleService::class)->enabled('directions_fare')) {
            $route = $this->mapsService->routeMetrics(
                (float) $validated['pickup_latitude'],
                (float) $validated['pickup_longitude'],
                (float) $validated['dropoff_latitude'],
                (float) $validated['dropoff_longitude'],
            );

            if ($route) {
                return [$route['distance_km'], $route['duration_minutes'], $route['source']];
            }
        }

        $distance = $this->fareCalculator->haversineDistance(
            (float) $validated['pickup_latitude'],
            (float) $validated['pickup_longitude'],
            (float) $validated['dropoff_latitude'],
            (float) $validated['dropoff_longitude'],
        );

        return [$distance, $this->fareCalculator->estimateEta($distance), 'haversine'];
    }
}
