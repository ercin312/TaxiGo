<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Complaint;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ComplaintController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $complaints = $request->user()
            ->complaints()
            ->with('ride')
            ->latest()
            ->paginate($request->integer('per_page', 15));

        return response()->json($complaints);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'ride_id' => ['sometimes', 'nullable', 'exists:rides,id'],
            'subject' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string', 'max:5000'],
        ]);

        $complaint = Complaint::query()->create([
            'user_id' => $request->user()->id,
            'ride_id' => $validated['ride_id'] ?? null,
            'subject' => $validated['subject'],
            'description' => $validated['description'],
            'status' => 'open',
        ]);

        return response()->json([
            'message' => 'Complaint submitted successfully.',
            'complaint' => $complaint,
        ], 201);
    }

    public function show(Request $request, Complaint $complaint): JsonResponse
    {
        if ($complaint->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        return response()->json(['complaint' => $complaint->load('ride')]);
    }
}
