<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Enums\RideStatus;
use App\Http\Controllers\Controller;
use App\Models\Ride;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminRideController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $terminalStatuses = [
            RideStatus::Completed,
            RideStatus::CancelledByPassenger,
            RideStatus::CancelledByDriver,
            RideStatus::Expired,
        ];

        $rides = Ride::query()
            ->with(['passenger:id,name,phone', 'driver.user:id,name,phone'])
            ->when($request->tab === 'active', fn ($q) => $q->whereNotIn('status', $terminalStatuses))
            ->when($request->tab === 'history', fn ($q) => $q->whereIn('status', $terminalStatuses))
            ->when($request->status, fn ($q, $status) => $q->where('status', $status))
            ->when($request->search, function ($query, $search) {
                $query->where('reference', 'like', "%{$search}%");
            })
            ->latest()
            ->paginate(min((int) $request->get('per_page', 30), 100));

        return response()->json($rides);
    }
}
