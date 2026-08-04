<?php

namespace App\Http\Controllers\Admin;

use App\Enums\RideStatus;
use App\Http\Controllers\Controller;
use App\Models\Driver;
use App\Models\Ride;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class RideController extends Controller
{
    public function index(Request $request): Response
    {
        $terminalStatuses = [
            RideStatus::Completed,
            RideStatus::CancelledByPassenger,
            RideStatus::CancelledByDriver,
            RideStatus::Expired,
        ];

        $rides = Ride::query()
            ->with(['passenger', 'driver.user'])
            ->when($request->tab === 'active', fn ($q) => $q->whereNotIn('status', $terminalStatuses))
            ->when($request->tab === 'history', fn ($q) => $q->whereIn('status', $terminalStatuses))
            ->when($request->status, fn ($q, $status) => $q->where('status', $status))
            ->when($request->search, function ($query, $search) {
                $query->where('reference', 'like', "%{$search}%");
            })
            ->latest()
            ->paginate(20)
            ->withQueryString();

        return Inertia::render('Admin/Rides/Index', [
            'rides' => $rides,
            'filters' => $request->only(['search', 'status', 'tab']),
            'statuses' => array_column(RideStatus::cases(), 'value'),
        ]);
    }

    public function liveMap(): Response
    {
        $terminalStatuses = [
            RideStatus::Completed,
            RideStatus::CancelledByPassenger,
            RideStatus::CancelledByDriver,
            RideStatus::Expired,
        ];

        return Inertia::render('Admin/Rides/LiveMap', [
            'rides' => Ride::query()
                ->with(['passenger', 'driver.user'])
                ->whereNotIn('status', $terminalStatuses)
                ->get(),
            'onlineDrivers' => Driver::query()
                ->with('user')
                ->where('is_online', true)
                ->whereNotNull('current_latitude')
                ->whereNotNull('current_longitude')
                ->get(),
        ]);
    }

    public function show(Ride $ride): Response
    {
        return Inertia::render('Admin/Rides/Show', [
            'ride' => $ride->load([
                'passenger',
                'driver.user',
                'driver.vehicle',
                'locations',
                'rating',
                'promoCode',
                'complaints',
            ]),
        ]);
    }
}
