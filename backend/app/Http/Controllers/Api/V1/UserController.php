<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        return response()->json([
            'user' => $request->user()->load('driver.vehicle', 'wallet'),
        ]);
    }

    public function update(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => ['sometimes', 'nullable', 'email', 'max:255', Rule::unique('users')->ignore($user->id)],
            'phone' => ['sometimes', 'nullable', 'string', 'max:20', Rule::unique('users')->ignore($user->id)],
            'avatar' => ['sometimes', 'nullable', 'string', 'max:500'],
            'fcm_token' => ['sometimes', 'nullable', 'string'],
        ]);

        $user->update($validated);

        return response()->json([
            'message' => 'Profile updated successfully.',
            'user' => $user->fresh()->load('driver.vehicle', 'wallet'),
        ]);
    }

    public function updateLocale(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'locale' => ['required', 'string', Rule::in(config('taxigo.supported_locales', ['en']))],
        ]);

        $request->user()->update(['locale' => $validated['locale']]);

        return response()->json([
            'message' => 'Locale updated successfully.',
            'locale' => $validated['locale'],
        ]);
    }

    public function destroy(Request $request): JsonResponse
    {
        $user = $request->user();
        $user->tokens()->delete();
        $user->update(['is_active' => false]);

        return response()->json(['message' => 'Account deactivated successfully.']);
    }
}
