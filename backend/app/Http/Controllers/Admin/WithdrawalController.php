<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use App\Models\WithdrawalRequest;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Inertia\Inertia;
use Inertia\Response;

class WithdrawalController extends Controller
{
    public function index(Request $request): Response
    {
        $withdrawals = WithdrawalRequest::query()
            ->with(['driver.user'])
            ->when($request->status, fn ($q, $status) => $q->where('status', $status))
            ->latest()
            ->paginate(20)
            ->withQueryString();

        return Inertia::render('Admin/Withdrawals/Index', [
            'withdrawals' => $withdrawals,
            'filters' => $request->only(['status']),
        ]);
    }

    public function approve(Request $request, WithdrawalRequest $withdrawal): RedirectResponse
    {
        if ($withdrawal->status !== 'pending') {
            return back()->with('error', 'Withdrawal request is not pending.');
        }

        $validated = $request->validate([
            'admin_note' => ['sometimes', 'nullable', 'string', 'max:1000'],
        ]);

        try {
            DB::transaction(function () use ($withdrawal, $validated) {
                $withdrawal = WithdrawalRequest::query()->lockForUpdate()->findOrFail($withdrawal->id);
                if ($withdrawal->status !== 'pending') {
                    throw new \RuntimeException('Withdrawal request is not pending.');
                }

                $userId = $withdrawal->driver?->user_id;
                if (! $userId) {
                    throw new \RuntimeException('Driver user not found.');
                }

                $wallet = Wallet::query()->lockForUpdate()->firstOrCreate(
                    ['user_id' => $userId],
                    ['balance' => 0, 'currency' => config('taxigo.currency', 'USD')],
                );

                if ((float) $wallet->balance < (float) $withdrawal->amount) {
                    throw new \RuntimeException('Insufficient wallet balance.');
                }

                $newBalance = (float) $wallet->balance - (float) $withdrawal->amount;
                $wallet->update(['balance' => $newBalance]);

                WalletTransaction::query()->create([
                    'wallet_id' => $wallet->id,
                    'type' => 'withdrawal',
                    'amount' => -1 * (float) $withdrawal->amount,
                    'balance_after' => $newBalance,
                    'description' => 'Driver withdrawal #'.$withdrawal->id,
                    'reference' => 'WD-'.strtoupper(Str::random(10)),
                ]);

                $withdrawal->update([
                    'status' => 'approved',
                    'admin_note' => $validated['admin_note'] ?? null,
                    'processed_at' => now(),
                ]);
            });
        } catch (\Throwable $e) {
            return back()->with('error', $e->getMessage());
        }

        return back()->with('success', 'Withdrawal approved and wallet debited.');
    }

    public function reject(Request $request, WithdrawalRequest $withdrawal): RedirectResponse
    {
        if ($withdrawal->status !== 'pending') {
            return back()->with('error', 'Withdrawal request is not pending.');
        }

        $validated = $request->validate([
            'rejection_reason' => ['required', 'string', 'max:1000'],
        ]);

        $withdrawal->update([
            'status' => 'rejected',
            'rejection_reason' => $validated['rejection_reason'],
            'processed_at' => now(),
        ]);

        return back()->with('success', 'Withdrawal rejected.');
    }
}
