<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class NotificationController extends Controller
{
    public function index(Request $request): Response
    {
        $notifications = Notification::query()
            ->with('user')
            ->latest()
            ->paginate(20);

        return Inertia::render('Admin/Notifications/Index', [
            'notifications' => $notifications,
            'roles' => ['passenger', 'driver', 'admin'],
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('Admin/Notifications/Create', [
            'roles' => ['passenger', 'driver', 'admin'],
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'body' => ['required', 'string', 'max:5000'],
            'type' => ['sometimes', 'string', 'max:50'],
            'user_id' => ['sometimes', 'nullable', 'exists:users,id'],
            'role' => ['sometimes', 'nullable', 'string'],
        ]);

        if (! empty($validated['user_id'])) {
            Notification::query()->create([
                'user_id' => $validated['user_id'],
                'title' => $validated['title'],
                'body' => $validated['body'],
                'type' => $validated['type'] ?? 'announcement',
            ]);
        } elseif (! empty($validated['role'])) {
            User::query()
                ->where('role', $validated['role'])
                ->where('is_active', true)
                ->chunk(100, function ($users) use ($validated) {
                    foreach ($users as $user) {
                        Notification::query()->create([
                            'user_id' => $user->id,
                            'title' => $validated['title'],
                            'body' => $validated['body'],
                            'type' => $validated['type'] ?? 'announcement',
                        ]);
                    }
                });
        } else {
            User::query()
                ->where('is_active', true)
                ->chunk(100, function ($users) use ($validated) {
                    foreach ($users as $user) {
                        Notification::query()->create([
                            'user_id' => $user->id,
                            'title' => $validated['title'],
                            'body' => $validated['body'],
                            'type' => $validated['type'] ?? 'announcement',
                        ]);
                    }
                });
        }

        return back()->with('success', 'Notification sent successfully.');
    }
}
