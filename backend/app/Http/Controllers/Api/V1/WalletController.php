<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use App\Services\FeatureModuleService;
use App\Services\WalletTopUpService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use RuntimeException;

class WalletController extends Controller
{
    public function __construct(
        protected WalletTopUpService $topUpService,
        protected FeatureModuleService $modules,
    ) {}

    public function show(Request $request): JsonResponse
    {
        $wallet = $this->getOrCreateWallet($request->user()->id);

        return response()->json([
            'wallet' => $wallet,
            'modules' => [
                'wallet_topup' => $this->modules->enabled('wallet_topup'),
                'withdrawals' => $this->modules->enabled('withdrawals'),
                'card_payments' => $this->modules->enabled('card_payments'),
            ],
            'presets' => config('taxigo.wallet.topup_presets', [5, 10, 20, 50, 100]),
            'min_topup' => (float) config('taxigo.wallet.min_topup', 5),
        ]);
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
        if ($this->modules->disabled('wallet_topup')) {
            return response()->json([
                'message' => 'Wallet top-up module is disabled by Super Admin.',
            ], 403);
        }

        $min = (float) config('taxigo.wallet.min_topup', 5);

        $validated = $request->validate([
            'amount' => ['required', 'numeric', 'min:'.$min],
            'description' => ['sometimes', 'nullable', 'string', 'max:255'],
            'payment_method' => ['sometimes', 'string', 'in:card,stub'],
        ]);

        try {
            $payment = $this->topUpService->charge(
                $request->user(),
                (float) $validated['amount'],
            );
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        if (($payment['status'] ?? '') !== 'captured') {
            return response()->json([
                'message' => 'Payment was not captured.',
                'payment' => $payment,
            ], 422);
        }

        $wallet = $this->getOrCreateWallet($request->user()->id);

        $transaction = DB::transaction(function () use ($wallet, $validated, $payment) {
            $locked = Wallet::query()->lockForUpdate()->findOrFail($wallet->id);
            $newBalance = (float) $locked->balance + (float) $validated['amount'];
            $locked->update(['balance' => $newBalance]);

            return WalletTransaction::query()->create([
                'wallet_id' => $locked->id,
                'type' => 'top_up',
                'amount' => $validated['amount'],
                'balance_after' => $newBalance,
                'description' => $validated['description']
                    ?? 'Wallet top-up ('.$payment['provider'].')',
                'reference' => $payment['reference'] ?? 'WT-'.strtoupper(Str::random(12)),
            ]);
        });

        return response()->json([
            'message' => 'Wallet topped up successfully.',
            'transaction' => $transaction,
            'wallet' => $wallet->fresh(),
            'payment' => [
                'provider' => $payment['provider'],
                'reference' => $payment['reference'],
                'status' => $payment['status'],
            ],
        ]);
    }

    protected function getOrCreateWallet(int $userId): Wallet
    {
        return Wallet::query()->firstOrCreate(
            ['user_id' => $userId],
            ['balance' => 0, 'currency' => config('taxigo.currency', 'EUR')],
        );
    }
}
