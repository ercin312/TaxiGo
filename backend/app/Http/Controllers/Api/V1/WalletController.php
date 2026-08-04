<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class WalletController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $wallet = $this->getOrCreateWallet($request->user()->id);

        return response()->json(['wallet' => $wallet]);
    }

    public function transactions(Request $request): JsonResponse
    {
        $wallet = $this->getOrCreateWallet($request->user()->id);

        $transactions = $wallet->transactions()
            ->latest()
            ->paginate($request->integer('per_page', 20));

        return response()->json($transactions);
    }

    public function topUp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'amount' => ['required', 'numeric', 'min:'.config('taxigo.wallet.min_topup', 5)],
            'description' => ['sometimes', 'nullable', 'string', 'max:255'],
        ]);

        $wallet = $this->getOrCreateWallet($request->user()->id);

        $transaction = DB::transaction(function () use ($wallet, $validated) {
            $newBalance = (float) $wallet->balance + (float) $validated['amount'];
            $wallet->update(['balance' => $newBalance]);

            return WalletTransaction::query()->create([
                'wallet_id' => $wallet->id,
                'type' => 'top_up',
                'amount' => $validated['amount'],
                'balance_after' => $newBalance,
                'description' => $validated['description'] ?? 'Wallet top-up',
                'reference' => 'WT-'.strtoupper(Str::random(12)),
            ]);
        });

        return response()->json([
            'message' => 'Wallet topped up successfully.',
            'transaction' => $transaction,
            'wallet' => $wallet->fresh(),
        ]);
    }

    protected function getOrCreateWallet(int $userId): Wallet
    {
        return Wallet::query()->firstOrCreate(
            ['user_id' => $userId],
            ['balance' => 0, 'currency' => config('taxigo.currency', 'USD')],
        );
    }
}
