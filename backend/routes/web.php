<?php

use App\Http\Controllers\Admin\ComplaintController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\DriverController;
use App\Http\Controllers\Admin\ModuleController;
use App\Http\Controllers\Admin\NotificationController;
use App\Http\Controllers\Admin\PromoController;
use App\Http\Controllers\Admin\RideController;
use App\Http\Controllers\Admin\SettingController;
use App\Http\Controllers\Admin\TariffController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\WithdrawalController;
use App\Http\Controllers\Api\V1\SharedTripController;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\LegalController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect()->route('admin.dashboard');
});

Route::get('privacy', [LegalController::class, 'privacy'])->name('legal.privacy');
Route::get('terms', [LegalController::class, 'terms'])->name('legal.terms');
Route::get('support', [LegalController::class, 'support'])->name('legal.support');
Route::get('delete-account', [LegalController::class, 'deleteAccount'])->name('legal.delete-account');

Route::get('shared/trip/{reference}', [SharedTripController::class, 'page'])
    ->name('shared.trip');

Route::middleware('guest')->group(function () {
    Route::get('login', [LoginController::class, 'create'])->name('login');
    Route::post('login', [LoginController::class, 'store']);
});

Route::post('logout', [LoginController::class, 'destroy'])->middleware('auth')->name('logout');

Route::middleware(['auth', 'admin'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');

    Route::get('users', [UserController::class, 'index'])->name('users.index');
    Route::get('users/{user}', [UserController::class, 'show'])->name('users.show');
    Route::put('users/{user}', [UserController::class, 'update'])->name('users.update');
    Route::delete('users/{user}', [UserController::class, 'destroy'])->name('users.destroy');

    Route::get('drivers', [DriverController::class, 'index'])->name('drivers.index');
    Route::get('drivers/{driver}', [DriverController::class, 'show'])->name('drivers.show');
    Route::post('drivers/{driver}/approve', [DriverController::class, 'approve'])->name('drivers.approve');
    Route::post('drivers/{driver}/reject', [DriverController::class, 'reject'])->name('drivers.reject');
    Route::post('drivers/{driver}/ban', [DriverController::class, 'ban'])->name('drivers.ban');
    Route::post('drivers/{driver}/documents/{document}/verify', [DriverController::class, 'verifyDocument'])
        ->name('drivers.documents.verify');
    Route::post('drivers/{driver}/documents/{document}/reject', [DriverController::class, 'rejectDocument'])
        ->name('drivers.documents.reject');

    Route::get('rides', [RideController::class, 'index'])->name('rides.index');
    Route::get('rides/live-map', [RideController::class, 'liveMap'])->name('rides.live-map');
    Route::get('rides/{ride}', [RideController::class, 'show'])->name('rides.show');

    Route::get('tariffs', [TariffController::class, 'index'])->name('tariffs.index');
    Route::post('tariffs', [TariffController::class, 'store'])->name('tariffs.store');
    Route::put('tariffs/{tariff}', [TariffController::class, 'update'])->name('tariffs.update');
    Route::delete('tariffs/{tariff}', [TariffController::class, 'destroy'])->name('tariffs.destroy');

    Route::get('promos', [PromoController::class, 'index'])->name('promos.index');
    Route::post('promos', [PromoController::class, 'store'])->name('promos.store');
    Route::put('promos/{promo}', [PromoController::class, 'update'])->name('promos.update');
    Route::delete('promos/{promo}', [PromoController::class, 'destroy'])->name('promos.destroy');

    Route::get('complaints', [ComplaintController::class, 'index'])->name('complaints.index');
    Route::get('complaints/{complaint}', [ComplaintController::class, 'show'])->name('complaints.show');
    Route::put('complaints/{complaint}', [ComplaintController::class, 'update'])->name('complaints.update');

    Route::get('settings', [SettingController::class, 'index'])->name('settings.index');
    Route::put('settings', [SettingController::class, 'update'])->name('settings.update');

    Route::middleware('super_admin')->group(function () {
        Route::get('modules', [ModuleController::class, 'index'])->name('modules.index');
        Route::put('modules', [ModuleController::class, 'update'])->name('modules.update');
    });

    Route::get('withdrawals', [WithdrawalController::class, 'index'])->name('withdrawals.index');
    Route::post('withdrawals/{withdrawal}/approve', [WithdrawalController::class, 'approve'])->name('withdrawals.approve');
    Route::post('withdrawals/{withdrawal}/reject', [WithdrawalController::class, 'reject'])->name('withdrawals.reject');

    Route::get('notifications', [NotificationController::class, 'index'])->name('notifications.index');
    Route::get('notifications/create', [NotificationController::class, 'create'])->name('notifications.create');
    Route::post('notifications', [NotificationController::class, 'store'])->name('notifications.store');
});
