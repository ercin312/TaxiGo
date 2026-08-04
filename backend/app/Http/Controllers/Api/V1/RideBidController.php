<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Ride;
use App\Models\RideBid;
use App\Services\RideBidService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RideBidController extends Controller
{
    public function __construct(
        protected RideBidService $bidService,
    ) {}

    protected function ensureBiddingEnabled(): void
    {
        if (app(\App\Services\FeatureModuleService::class)->disabled('bidding')) {
            abort(403, 'Bidding module is disabled.');
        }
    }

    public function index(Request $request, Ride $ride): JsonResponse
    {
        $this->ensureBiddingEnabled();

        if ($ride->passenger_id !== $request->user()->id) {
            abort(403, 'Unauthorized access to this ride.');
        }

        $bids = $this->bidService->listActiveBids($ride);

        return response()->json([
            'bids' => $bids,
            'ride' => $ride->fresh(),
        ]);
    }

    public function accept(Request $request, Ride $ride, RideBid $bid): JsonResponse
    {
        $this->ensureBiddingEnabled();

        if ($ride->passenger_id !== $request->user()->id) {
            abort(403, 'Unauthorized access to this ride.');
        }

        if ($bid->ride_id !== $ride->id) {
            abort(404, 'Bid not found for this ride.');
        }

        try {
            $ride = $this->bidService->acceptBid($ride, $bid);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'message' => 'Bid accepted. Driver assigned.',
            'ride' => $ride,
        ]);
    }

    public function reject(Request $request, Ride $ride, RideBid $bid): JsonResponse
    {
        $this->ensureBiddingEnabled();

        if ($ride->passenger_id !== $request->user()->id) {
            abort(403, 'Unauthorized access to this ride.');
        }

        if ($bid->ride_id !== $ride->id) {
            abort(404, 'Bid not found for this ride.');
        }

        try {
            $bid = $this->bidService->rejectBid($bid);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'message' => 'Bid rejected.',
            'bid' => $bid,
        ]);
    }

    public function updateOffer(Request $request, Ride $ride): JsonResponse
    {
        $this->ensureBiddingEnabled();

        if ($ride->passenger_id !== $request->user()->id) {
            abort(403, 'Unauthorized access to this ride.');
        }

        $validated = $request->validate([
            'offered_fare' => ['required', 'numeric', 'min:0'],
        ]);

        try {
            $ride = $this->bidService->updateOffer(
                $ride,
                (float) $validated['offered_fare'],
            );
        } catch (\InvalidArgumentException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'message' => 'Offer updated.',
            'ride' => $ride,
        ]);
    }
}
