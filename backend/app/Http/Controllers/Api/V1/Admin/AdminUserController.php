<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminUserController extends Controller
{
    public function index(Request $request): JsonResponse
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
            ->paginate(min((int) $request->get('per_page', 30), 100));

        return response()->json($users);
    }

    public function update(Request $request, User $user): JsonResponse
    {
        $validated = $request->validate([
            'is_active' => ['sometimes', 'boolean'],
            'name' => ['sometimes', 'string', 'max:255'],
        ]);

        $user->update($validated);

        return response()->json(['user' => $user->fresh()]);
    }
}
