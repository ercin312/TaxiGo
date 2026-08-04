<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\PromoCode;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class PromoController extends Controller
{
    public function index(): Response
    {
        return Inertia::render('Admin/Promos/Index', [
            'promoCodes' => PromoCode::query()->latest()->paginate(20),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'code' => ['required', 'string', 'max:50', 'unique:promo_codes,code'],
            'description' => ['sometimes', 'nullable', 'string', 'max:255'],
            'discount_type' => ['required', 'in:percentage,fixed'],
            'discount_value' => ['required', 'numeric', 'min:0'],
            'max_discount' => ['sometimes', 'nullable', 'numeric', 'min:0'],
            'min_fare' => ['sometimes', 'nullable', 'numeric', 'min:0'],
            'max_uses' => ['sometimes', 'nullable', 'integer', 'min:1'],
            'per_user_limit' => ['sometimes', 'integer', 'min:1'],
            'is_active' => ['sometimes', 'boolean'],
            'starts_at' => ['sometimes', 'nullable', 'date'],
            'expires_at' => ['sometimes', 'nullable', 'date', 'after:starts_at'],
        ]);

        $validated['code'] = strtoupper($validated['code']);

        PromoCode::query()->create($validated);

        return back()->with('success', 'Promo code created successfully.');
    }

    public function update(Request $request, PromoCode $promo): RedirectResponse
    {
        $validated = $request->validate([
            'description' => ['sometimes', 'nullable', 'string', 'max:255'],
            'discount_type' => ['sometimes', 'in:percentage,fixed'],
            'discount_value' => ['sometimes', 'numeric', 'min:0'],
            'max_discount' => ['sometimes', 'nullable', 'numeric', 'min:0'],
            'min_fare' => ['sometimes', 'nullable', 'numeric', 'min:0'],
            'max_uses' => ['sometimes', 'nullable', 'integer', 'min:1'],
            'per_user_limit' => ['sometimes', 'integer', 'min:1'],
            'is_active' => ['sometimes', 'boolean'],
            'starts_at' => ['sometimes', 'nullable', 'date'],
            'expires_at' => ['sometimes', 'nullable', 'date'],
        ]);

        $promo->update($validated);

        return back()->with('success', 'Promo code updated successfully.');
    }

    public function destroy(PromoCode $promo): RedirectResponse
    {
        $promo->update(['is_active' => false]);

        return back()->with('success', 'Promo code deactivated.');
    }
}
