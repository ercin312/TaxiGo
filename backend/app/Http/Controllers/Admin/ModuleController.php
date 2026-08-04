<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\FeatureModuleService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class ModuleController extends Controller
{
    public function __construct(
        protected FeatureModuleService $modules,
    ) {}

    public function index(): Response
    {
        $this->modules->seedDefaults();

        $catalog = $this->modules->catalog();
        $grouped = collect($catalog)->groupBy('category')->map(fn ($items) => $items->values())->all();

        return Inertia::render('Admin/Modules/Index', [
            'modules' => $catalog,
            'grouped' => $grouped,
            'categories' => [
                'auth' => 'Auth',
                'maps' => 'Maps',
                'payments' => 'Payments',
                'realtime' => 'Realtime',
                'safety' => 'Safety',
                'rides' => 'Rides',
            ],
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'modules' => ['required', 'array'],
            'modules.*' => ['boolean'],
        ]);

        $allowed = array_keys($this->modules->definitions());
        $payload = [];
        foreach ($validated['modules'] as $key => $enabled) {
            if (in_array($key, $allowed, true)) {
                $payload[$key] = (bool) $enabled;
            }
        }

        $this->modules->sync($payload);

        return back()->with('success', 'Modules updated successfully.');
    }
}
