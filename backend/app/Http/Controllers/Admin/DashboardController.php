<?php

namespace App\Http\Controllers\Admin;

use App\Enums\DriverApprovalStatus;
use App\Enums\RideStatus;
use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\Complaint;
use App\Models\Driver;
use App\Models\Ride;
use App\Models\User;
use App\Models\WithdrawalRequest;
use Inertia\Inertia;
use Inertia\Response;

class DashboardController extends Controller
{
    public function index(): Response
    {
        return Inertia::render('Admin/Dashboard', [
            'stats' => [
                'total_users' => User::query()->count(),
                'total_passengers' => User::query()->where('role', UserRole::Passenger)->count(),
                'total_drivers' => Driver::query()->count(),
                'pending_drivers' => Driver::query()->where('approval_status', DriverApprovalStatus::Pending)->count(),
                'online_drivers' => Driver::query()->where('is_online', true)->count(),
                'total_rides' => Ride::query()->count(),
                'active_rides' => Ride::query()
                    ->whereNotIn('status', [
                        RideStatus::Completed,
                        RideStatus::CancelledByPassenger,
                        RideStatus::CancelledByDriver,
                        RideStatus::Expired,
                    ])
                    ->count(),
                'completed_rides_today' => Ride::query()
                    ->where('status', RideStatus::Completed)
                    ->whereDate('completed_at', today())
                    ->count(),
                'open_complaints' => Complaint::query()->whereIn('status', ['open', 'urgent'])->count(),
                'pending_withdrawals' => WithdrawalRequest::query()->where('status', 'pending')->count(),
            ],
            'recent_rides' => Ride::query()
                ->with(['passenger', 'driver.user'])
                ->latest()
                ->limit(10)
                ->get(),
        ]);
    }
}
