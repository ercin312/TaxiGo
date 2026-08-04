<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\RideStatus;
use App\Exceptions\InvalidRideTransitionException;
use App\Http\Controllers\Controller;
use App\Models\Ride;
use App\Services\FirebaseRtdbService;
use App\Services\RideBidService;
use App\Services\RideMatchingService;
use App\Services\RideSettlementService;
use App\Services\RideStatusService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use RuntimeException;

class DriverRideController extends Controller
{
    public function __construct(
        protected RideStatusService $statusService,
        protected RideSettlementService $settlementService,
        protected FirebaseRtdbService $rtdbService,
        protected RideBidService $bidService,
        protected RideMatchingService $matchingService,
    ) {}

    public function pending(Request $request): JsonResponse
    {
        $driver = $request->user()->driver;

        if (! $driver) {
            return response()->json(['message' => 'Driver profile not found.'], 404);
        }

        $query = Ride::query()
            ->where('status', RideStatus::Pending)
            ->whereNull('driver_id')
            ->where(function ($q) {
                $q->whereNull('expires_at')
                    ->orWhere('expires_at', '>', now());
            })
            ->latest();

        $rides = $query->paginate($request->integer('per_page', 15));

        if ($driver->current_latitude && $driver->current_longitude) {
            $radius = config('taxigo.matching.radius_km', 5.0);
            $collection = collect($rides->items())->filter(function (Ride $ride) use ($driver, $radius) {
                $distance = $this->matchingService->distanceKm(
                    (float) $driver->current_latitude,
                    (float) $driver->current_longitude,
                    (float) $ride->pickup_latitude,
                    (float) $ride->pickup_longitude,
                );

                return $distance <= $radius * 2;
            })->values();

            return response()->json([
                'data' => $collection,
                'current_page' => $rides->currentPage(),
                'per_page' => $rides->perPage(),
                'total' => $collection->count(),
            ]);
        }

        return response()->json($rides);
    }

    public function active(Request $request): JsonResponse
    {
        $driver = $request->user()->driver;

        if (! $driver) {
            return response()->json(['message' => 'Driver profile not found.'], 404);
        }

        $ride = $driver->rides()
            ->whereNotIn('status', [
                RideStatus::Completed,
                RideStatus::CancelledByPassenger,
                RideStatus::CancelledByDriver,
                RideStatus::Expired,
            ])
            ->latest()
            ->with(['passenger', 'locations'])
            ->first();

        return response()->json(['ride' => $ride]);
    }

    public function history(Request $request): JsonResponse
    {
        $driver = $request->user()->driver;

        if (! $driver) {
            return response()->json(['message' => 'Driver profile not found.'], 404);
        }

        $rides = $driver->rides()
            ->with(['passenger', 'rating'])
            ->latest()
            ->paginate($request->integer('per_page', 15));

        return response()->json($rides);
    }

    public function accept(Request $request, Ride $ride): JsonResponse
    {
        $driver = $this->getDriver($request);

        if ($ride->status !== RideStatus::Pending || $ride->driver_id !== null) {
            return response()->json(['message' => 'Ride is no longer available.'], 422);
        }

        if ($ride->is_bidding) {
            try {
                $amount = (float) ($ride->offered_fare ?? $ride->estimated_fare);
                $bid = $this->bidService->submitBid($ride, $driver, $amount);
            } catch (\InvalidArgumentException $e) {
                return response()->json(['message' => $e->getMessage()], 422);
            } catch (\RuntimeException $e) {
                return response()->json(['message' => $e->getMessage()], 422);
            }

            return response()->json([
                'message' => 'Bid submitted at passenger offer.',
                'bid' => $bid,
            ]);
        }

        try {
            $ride = $this->statusService->transition($ride, RideStatus::DriverAssigned, [
                'driver_id' => $driver->id,
            ]);
            $ride = $this->statusService->transition($ride, RideStatus::DriverArriving);
        } catch (InvalidRideTransitionException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        $this->rtdbService->syncRide($ride);

        return response()->json([
            'message' => 'Ride accepted.',
            'ride' => $ride->load('passenger'),
        ]);
    }

    public function bid(Request $request, Ride $ride): JsonResponse
    {
        $driver = $this->getDriver($request);

        $validated = $request->validate([
            'amount' => ['required', 'numeric', 'min:0'],
        ]);

        try {
            $bid = $this->bidService->submitBid(
                $ride,
                $driver,
                (float) $validated['amount'],
            );
        } catch (\InvalidArgumentException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'message' => 'Bid submitted.',
            'bid' => $bid,
        ]);
    }

    public function reject(Request $request, Ride $ride): JsonResponse
    {
        $this->getDriver($request);

        return response()->json(['message' => 'Ride rejected.']);
    }

    public function arrived(Request $request, Ride $ride): JsonResponse
    {
        $driver = $this->getDriver($request);
        $this->ensureDriverOwnsRide($driver, $ride);

        try {
            $ride = $this->statusService->transition($ride, RideStatus::DriverArrived);
        } catch (InvalidRideTransitionException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        $this->rtdbService->syncRide($ride);

        return response()->json([
            'message' => 'Marked as arrived.',
            'ride' => $ride,
        ]);
    }

    public function start(Request $request, Ride $ride): JsonResponse
    {
        $driver = $this->getDriver($request);
        $this->ensureDriverOwnsRide($driver, $ride);

        try {
            if ($ride->status === RideStatus::DriverArrived) {
                $ride = $this->statusService->transition($ride, RideStatus::PassengerOnBoard);
            }
            $ride = $this->statusService->transition($ride, RideStatus::InProgress);
        } catch (InvalidRideTransitionException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        $this->rtdbService->syncRide($ride);

        return response()->json([
            'message' => 'Ride started.',
            'ride' => $ride,
        ]);
    }

    public function complete(Request $request, Ride $ride): JsonResponse
    {
        $driver = $this->getDriver($request);
        $this->ensureDriverOwnsRide($driver, $ride);

        $validated = $request->validate([
            'distance_km' => ['sometimes', 'numeric', 'min:0'],
            'duration_minutes' => ['sometimes', 'integer', 'min:0'],
        ]);

        try {
            $ride = $this->statusService->transition($ride, RideStatus::Completed, [
                'final_fare' => $ride->estimated_fare,
                'distance_km' => $validated['distance_km'] ?? $ride->estimated_distance_km,
                'duration_minutes' => $validated['duration_minutes'] ?? $ride->estimated_duration_minutes,
            ]);
        } catch (InvalidRideTransitionException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        try {
            $ride = $this->settlementService->settle($ride);
        } catch (RuntimeException $e) {
            // Roll status back is complex; mark as completed but unpaid settlement error.
            return response()->json([
                'message' => $e->getMessage(),
                'ride' => $ride->fresh(),
                'settlement_failed' => true,
            ], 422);
        }

        $driver->increment('total_rides');
        $this->rtdbService->syncRide($ride);

        return response()->json([
            'message' => 'Ride completed.',
            'ride' => $ride,
        ]);
    }

    public function cancel(Request $request, Ride $ride): JsonResponse
    {
        $driver = $this->getDriver($request);
        $this->ensureDriverOwnsRide($driver, $ride);

        $validated = $request->validate([
            'reason' => ['sometimes', 'nullable', 'string', 'max:500'],
        ]);

        try {
            $ride = $this->statusService->transition($ride, RideStatus::CancelledByDriver, [
                'cancellation_reason' => $validated['reason'] ?? null,
            ]);
        } catch (InvalidRideTransitionException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        $this->rtdbService->syncRide($ride);

        return response()->json([
            'message' => 'Ride cancelled.',
            'ride' => $ride,
        ]);
    }

    protected function getDriver(Request $request)
    {
        $driver = $request->user()->driver;

        if (! $driver || ! $driver->isApproved()) {
            abort(403, 'Approved driver profile required.');
        }

        return $driver;
    }

    protected function ensureDriverOwnsRide($driver, Ride $ride): void
    {
        if ($ride->driver_id !== $driver->id) {
            abort(403, 'This ride is not assigned to you.');
        }
    }
}
