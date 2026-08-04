<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use App\Models\WithdrawalRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class WithdrawalApiController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        if (app(\App\Services\FeatureModuleService::class)->disabled('withdrawals')) {
            return response()->json(['message' => 'Withdrawals module is disabled.'], 403);
        }

        $driver = $request->user()->driver;
        if (! $driver) {
            return response()->json(['message' => 'Driver profile not found.'], 404);
        }

        $items = WithdrawalRequest::query()
            ->where('driver_id', $driver->id)
            ->latest()
            ->paginate($request->integer('per_page', 20));

        return response()->json($items);
    }

    public function store(Request $request): JsonResponse
    {
        if (app(\App\Services\FeatureModuleService::class)->disabled('withdrawals')) {
            return response()->json(['message' => 'Withdrawals module is disabled.'], 403);
        }

        $driver = $request->user()->driver;
        if (! $driver || ! $driver->isApproved()) {
            return response()->json(['message' => 'Approved driver required.'], 403);
        }

        $min = (float) config('taxigo.wallet.min_withdrawal', 20);

        $validated = $request->validate([
            'amount' => ['required', 'numeric', 'min:'.$min],
            'bank_name' => ['required', 'string', 'max:100'],
            'account_number' => ['required', 'string', 'max:50'],
            'account_holder' => ['required', 'string', 'max:100'],
        ]);

        $wallet = Wallet::query()->firstOrCreate(
            ['user_id' => $request->user()->id],
            ['balance' => 0, 'currency' => config('taxigo.currency', 'USD')],
        );

        if ((float) $wallet->balance < (float) $validated['amount']) {
            return response()->json(['message' => 'Insufficient wallet balance.'], 422);
        }

        $pending = WithdrawalRequest::query()
            ->where('driver_id', $driver->id)
            ->where('status', 'pending')
            ->exists();

        if ($pending) {
            return response()->json(['message' => 'You already have a pending withdrawal.'], 422);
        }

        $withdrawal = WithdrawalRequest::query()->create([
            'driver_id' => $driver->id,
            'amount' => $validated['amount'],
            'status' => 'pending',
            'bank_name' => $validated['bank_name'],
            'account_number' => $validated['account_number'],
            'account_holder' => $validated['account_holder'],
        ]);

        return response()->json([
            'message' => 'Withdrawal requested.',
            'withdrawal' => $withdrawal,
            'wallet' => $wallet,
        ], 201);
    }
}
