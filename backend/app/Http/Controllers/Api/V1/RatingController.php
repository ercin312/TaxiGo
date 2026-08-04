<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\RideStatus;
use App\Http\Controllers\Controller;
use App\Models\Driver;
use App\Models\Ride;
use App\Models\RideRating;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RatingController extends Controller
{
    public function store(Request $request, Ride $ride): JsonResponse
    {
        $user = $request->user();

        if ($ride->status !== RideStatus::Completed) {
            return response()->json(['message' => 'Only completed rides can be rated.'], 422);
        }

        if ($ride->rating) {
            return response()->json(['message' => 'Ride has already been rated.'], 422);
        }

        $isPassenger = $ride->passenger_id === $user->id;
        $isDriver = $user->driver && $ride->driver_id === $user->driver->id;

        if (! $isPassenger && ! $isDriver) {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        $validated = $request->validate([
            'rating' => ['required', 'integer', 'min:1', 'max:5'],
            'comment' => ['sometimes', 'nullable', 'string', 'max:1000'],
        ]);

        $ratedId = $isPassenger
            ? $ride->driver?->user_id
            : $ride->passenger_id;

        if (! $ratedId) {
            return response()->json(['message' => 'Cannot determine rated user.'], 422);
        }

        $rating = DB::transaction(function () use ($ride, $user, $ratedId, $validated) {
            $rating = RideRating::query()->create([
                'ride_id' => $ride->id,
                'rater_id' => $user->id,
                'rated_id' => $ratedId,
                'rating' => $validated['rating'],
                'comment' => $validated['comment'] ?? null,
            ]);

            if ($ride->driver_id) {
                $this->updateDriverRating($ride->driver_id);
            }

            return $rating;
        });

        return response()->json([
            'message' => 'Rating submitted successfully.',
            'rating' => $rating,
        ], 201);
    }

    protected function updateDriverRating(int $driverId): void
    {
        $driver = Driver::query()->find($driverId);

        if (! $driver) {
            return;
        }

        $ratings = RideRating::query()
            ->where('rated_id', $driver->user_id)
            ->get();

        $driver->update([
            'rating_count' => $ratings->count(),
            'rating_average' => $ratings->count() > 0
                ? round($ratings->avg('rating'), 2)
                : 0,
        ]);
    }
}
