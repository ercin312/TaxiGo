<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class UserController extends Controller
{
    public function index(Request $request): Response
    {
        $users = User::query()
            ->when($request->search, function ($query, $search) {
                $query->where(function ($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%")
                        ->orWhere('phone', 'like', "%{$search}%");
                });
            })
            ->when($request->role, fn ($q, $role) => $q->where('role', $role))
            ->latest()
            ->paginate(20)
            ->withQueryString();

        return Inertia::render('Admin/Users/Index', [
            'users' => $users,
            'filters' => $request->only(['search', 'role']),
            'roles' => array_column(UserRole::cases(), 'value'),
        ]);
    }

    public function show(User $user): Response
    {
        return Inertia::render('Admin/Users/Show', [
            'user' => $user->load('driver.vehicle', 'wallet', 'passengerRides'),
        ]);
    }

    public function update(Request $request, User $user): RedirectResponse
    {
        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => ['sometimes', 'nullable', 'email', 'max:255'],
            'phone' => ['sometimes', 'nullable', 'string', 'max:20'],
            'role' => ['sometimes', 'string'],
            'is_active' => ['sometimes', 'boolean'],
        ]);

        $user->update($validated);

        return back()->with('success', 'User updated successfully.');
    }

    public function destroy(User $user): RedirectResponse
    {
        if ($user->isAdmin()) {
            return back()->with('error', 'Cannot delete admin users.');
        }

        $user->update(['is_active' => false]);

        return back()->with('success', 'User deactivated successfully.');
    }
}
