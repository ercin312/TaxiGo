<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\Admin\AdminAuthController;
use App\Http\Controllers\Api\V1\Admin\AdminDashboardController;
use App\Http\Controllers\Api\V1\Admin\AdminDriverController;
use App\Http\Controllers\Api\V1\Admin\AdminRideController;
use App\Http\Controllers\Api\V1\Admin\AdminUserController;
use App\Http\Controllers\Api\V1\ComplaintController;
use App\Http\Controllers\Api\V1\DeviceController;
use App\Http\Controllers\Api\V1\DriverController;
use App\Http\Controllers\Api\V1\DriverRideController;
use App\Http\Controllers\Api\V1\MapsController;
use App\Http\Controllers\Api\V1\ModuleConfigController;
use App\Http\Controllers\Api\V1\PaymentWebhookController;
use App\Http\Controllers\Api\V1\PromoController;
use App\Http\Controllers\Api\V1\RatingController;
use App\Http\Controllers\Api\V1\RideBidController;
use App\Http\Controllers\Api\V1\RideController;
use App\Http\Controllers\Api\V1\SafetyController;
use App\Http\Controllers\Api\V1\SharedTripController;
use App\Http\Controllers\Api\V1\UserController;
use App\Http\Controllers\Api\V1\WalletController;
use App\Http\Controllers\Api\V1\WithdrawalApiController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::post('auth/otp/request', [AuthController::class, 'requestOtp'])
        ->middleware('throttle:10,1');
    Route::post('auth/otp/verify', [AuthController::class, 'verifyOtp'])
        ->middleware('throttle:20,1');
    // Demo login (TAXIGO_DEMO_LOGIN). Prefer WhatsApp OTP above.
    Route::post('auth/demo-login', [AuthController::class, 'demoLogin'])
        ->middleware('throttle:20,1');
    Route::post('auth/firebase-verify', [AuthController::class, 'firebaseVerify']);
    Route::post('devices/register', [DeviceController::class, 'register']);

    // Windows / native admin panel
    Route::prefix('admin')->group(function () {
        Route::post('login', [AdminAuthController::class, 'login'])
            ->middleware('throttle:20,1');

        Route::middleware(['auth:sanctum', 'admin'])->group(function () {
            Route::get('me', [AdminAuthController::class, 'me']);
            Route::post('logout', [AdminAuthController::class, 'logout']);
            Route::get('dashboard', AdminDashboardController::class);
            Route::get('users', [AdminUserController::class, 'index']);
            Route::patch('users/{user}', [AdminUserController::class, 'update']);
            Route::get('drivers', [AdminDriverController::class, 'index']);
            Route::get('drivers/{driver}', [AdminDriverController::class, 'show']);
            Route::post('drivers/{driver}/approve', [AdminDriverController::class, 'approve']);
            Route::post('drivers/{driver}/reject', [AdminDriverController::class, 'reject']);
            Route::post('drivers/{driver}/ban', [AdminDriverController::class, 'ban']);
            Route::post('drivers/{driver}/documents/{document}/verify', [AdminDriverController::class, 'verifyDocument']);
            Route::post('drivers/{driver}/documents/{document}/reject', [AdminDriverController::class, 'rejectDocument']);
            Route::get('rides', [AdminRideController::class, 'index']);
        });
    });

    Route::get('shared/trips/{reference}', [SharedTripController::class, 'show'])
        ->middleware('throttle:60,1');
    Route::get('modules', [ModuleConfigController::class, 'index'])
        ->middleware('throttle:60,1');
    Route::post('payments/iyzico/callback', [PaymentWebhookController::class, 'iyzicoCallback'])
        ->middleware('throttle:60,1');

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('auth/logout', [AuthController::class, 'logout']);

        Route::get('user', [UserController::class, 'show']);
        Route::put('user', [UserController::class, 'update']);
        Route::patch('user/locale', [UserController::class, 'updateLocale']);
        Route::delete('user', [UserController::class, 'destroy']);

        Route::prefix('driver')->group(function () {
            Route::post('register', [DriverController::class, 'register']);
            Route::get('profile', [DriverController::class, 'show']);
            Route::post('documents', [DriverController::class, 'uploadDocument']);
            Route::post('online', [DriverController::class, 'goOnline']);
            Route::post('offline', [DriverController::class, 'goOffline']);
            Route::post('location', [DriverController::class, 'updateLocation']);
        });

        Route::prefix('rides')->group(function () {
            Route::post('eta', [RideController::class, 'eta']);
            Route::get('active', [RideController::class, 'active']);
            Route::get('history', [RideController::class, 'history']);
            Route::post('/', [RideController::class, 'store']);
            Route::get('{ride}', [RideController::class, 'show']);
            Route::post('{ride}/cancel', [RideController::class, 'cancel']);
            Route::post('{ride}/rate', [RatingController::class, 'store']);
            Route::post('{ride}/share', [SafetyController::class, 'shareTrip']);
            Route::get('{ride}/bids', [RideBidController::class, 'index']);
            Route::patch('{ride}/offer', [RideBidController::class, 'updateOffer']);
            Route::post('{ride}/bids/{bid}/accept', [RideBidController::class, 'accept']);
            Route::post('{ride}/bids/{bid}/reject', [RideBidController::class, 'reject']);
        });

        Route::prefix('driver/rides')->group(function () {
            Route::get('pending', [DriverRideController::class, 'pending']);
            Route::get('active', [DriverRideController::class, 'active']);
            Route::get('history', [DriverRideController::class, 'history']);
            Route::post('{ride}/accept', [DriverRideController::class, 'accept']);
            Route::post('{ride}/bid', [DriverRideController::class, 'bid']);
            Route::post('{ride}/reject', [DriverRideController::class, 'reject']);
            Route::post('{ride}/arrived', [DriverRideController::class, 'arrived']);
            Route::post('{ride}/start', [DriverRideController::class, 'start']);
            Route::post('{ride}/complete', [DriverRideController::class, 'complete']);
            Route::post('{ride}/cancel', [DriverRideController::class, 'cancel']);
        });

        Route::prefix('wallet')->group(function () {
            Route::get('/', [WalletController::class, 'show']);
            Route::get('transactions', [WalletController::class, 'transactions']);
            Route::post('top-up', [WalletController::class, 'topUp']);
            Route::get('withdrawals', [WithdrawalApiController::class, 'index']);
            Route::post('withdrawals', [WithdrawalApiController::class, 'store']);
        });

        Route::prefix('maps')->group(function () {
            Route::post('directions', [MapsController::class, 'directions']);
            Route::get('places', [MapsController::class, 'placesAutocomplete']);
            Route::get('place-details', [MapsController::class, 'placeDetails']);
        });

        Route::post('promo/validate', [PromoController::class, 'validateCode']);

        Route::prefix('complaints')->group(function () {
            Route::get('/', [ComplaintController::class, 'index']);
            Route::post('/', [ComplaintController::class, 'store']);
            Route::get('{complaint}', [ComplaintController::class, 'show']);
        });

        Route::post('safety/sos', [SafetyController::class, 'sos']);
    });
});
