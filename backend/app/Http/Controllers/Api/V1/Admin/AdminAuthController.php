<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AdminAuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = User::query()->where('email', $validated['email'])->first();

        if (! $user || ! Hash::check($validated['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['E-posta veya şifre hatalı.'],
            ]);
        }

        if (! $user->isAdmin()) {
            return response()->json(['message' => 'Bu hesap admin değil.'], 403);
        }

        if (! $user->is_active) {
            return response()->json(['message' => 'Hesap pasif.'], 403);
        }

        $user->tokens()->where('name', 'windows-admin')->delete();
        $token = $user->createToken('windows-admin')->plainTextToken;

        return response()->json([
            'token' => $token,
            'token_type' => 'Bearer',
            'user' => $this->adminUserPayload($user),
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'user' => $this->adminUserPayload($request->user()),
        ]);
    }

    /**
     * @return array{id: int, name: string, email: string|null, role: mixed, is_super_admin: bool}
     */
    private function adminUserPayload(User $user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role?->value ?? $user->role,
            'is_super_admin' => $user->isSuperAdmin(),
        ];
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()?->delete();

        return response()->json(['message' => 'Logged out.']);
    }
}
