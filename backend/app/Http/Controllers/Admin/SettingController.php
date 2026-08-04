<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class SettingController extends Controller
{
    public function index(): Response
    {
        return Inertia::render('Admin/Settings/Index', [
            'settings' => Setting::query()->orderBy('group')->orderBy('key')->get(),
            'defaults' => [
                'commission_rate' => config('taxigo.commission_rate'),
                'ride_expiry_minutes' => config('taxigo.ride_expiry_minutes'),
                'matching_radius_km' => config('taxigo.matching.radius_km'),
                'currency' => config('taxigo.currency'),
            ],
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'settings' => ['required', 'array'],
            'settings.*.key' => ['required', 'string'],
            'settings.*.value' => ['nullable'],
            'settings.*.type' => ['sometimes', 'string'],
            'settings.*.group' => ['sometimes', 'string'],
        ]);

        foreach ($validated['settings'] as $setting) {
            Setting::setValue(
                $setting['key'],
                $setting['value'],
                $setting['type'] ?? 'string',
                $setting['group'] ?? 'general',
            );
        }

        return back()->with('success', 'Settings updated successfully.');
    }
}
