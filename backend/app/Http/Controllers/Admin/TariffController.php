<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\FareTariff;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class TariffController extends Controller
{
    public function index(): Response
    {
        return Inertia::render('Admin/Tariffs/Index', [
            'tariffs' => FareTariff::query()->latest()->paginate(20),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'vehicle_type' => ['required', 'string', 'max:50'],
            'base_fare' => ['required', 'numeric', 'min:0'],
            'per_km_rate' => ['required', 'numeric', 'min:0'],
            'per_minute_rate' => ['required', 'numeric', 'min:0'],
            'minimum_fare' => ['required', 'numeric', 'min:0'],
            'surge_multiplier' => ['sometimes', 'numeric', 'min:1'],
            'currency' => ['sometimes', 'string', 'size:3'],
            'is_active' => ['sometimes', 'boolean'],
        ]);

        FareTariff::query()->create($validated);

        return back()->with('success', 'Tariff created successfully.');
    }

    public function update(Request $request, FareTariff $tariff): RedirectResponse
    {
        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'vehicle_type' => ['sometimes', 'string', 'max:50'],
            'base_fare' => ['sometimes', 'numeric', 'min:0'],
            'per_km_rate' => ['sometimes', 'numeric', 'min:0'],
            'per_minute_rate' => ['sometimes', 'numeric', 'min:0'],
            'minimum_fare' => ['sometimes', 'numeric', 'min:0'],
            'surge_multiplier' => ['sometimes', 'numeric', 'min:1'],
            'currency' => ['sometimes', 'string', 'size:3'],
            'is_active' => ['sometimes', 'boolean'],
        ]);

        $tariff->update($validated);

        return back()->with('success', 'Tariff updated successfully.');
    }

    public function destroy(FareTariff $tariff): RedirectResponse
    {
        $tariff->delete();

        return back()->with('success', 'Tariff deleted successfully.');
    }
}
