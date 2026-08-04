<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\DocumentType;
use App\Enums\DriverApprovalStatus;
use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\Driver;
use App\Models\DriverDocument;
use App\Services\FirebaseRtdbService;
use App\Services\RideMatchingService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class DriverController extends Controller
{
    public function __construct(
        protected RideMatchingService $matchingService,
        protected FirebaseRtdbService $rtdbService,
    ) {}

    public function register(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->driver) {
            return response()->json(['message' => 'Driver profile already exists.'], 422);
        }

        $validated = $request->validate([
            'make' => ['required', 'string', 'max:100'],
            'model' => ['required', 'string', 'max:100'],
            'year' => ['required', 'integer', 'min:1990', 'max:'.(date('Y') + 1)],
            'color' => ['required', 'string', 'max:50'],
            'plate_number' => ['required', 'string', 'max:20', 'unique:vehicles,plate_number'],
            'vehicle_type' => ['sometimes', 'string', 'max:50'],
            'seats' => ['sometimes', 'integer', 'min:1', 'max:8'],
        ]);

        $driver = DB::transaction(function () use ($user, $validated) {
            $user->update(['role' => UserRole::Driver]);

            $driver = Driver::query()->create([
                'user_id' => $user->id,
                'approval_status' => DriverApprovalStatus::Pending,
            ]);

            $driver->vehicle()->create([
                'make' => $validated['make'],
                'model' => $validated['model'],
                'year' => $validated['year'],
                'color' => $validated['color'],
                'plate_number' => $validated['plate_number'],
                'vehicle_type' => $validated['vehicle_type'] ?? 'standard',
                'seats' => $validated['seats'] ?? 4,
            ]);

            return $driver;
        });

        return response()->json([
            'message' => 'Driver registration submitted for approval.',
            'driver' => $driver->load('vehicle', 'documents'),
        ], 201);
    }

    public function show(Request $request): JsonResponse
    {
        $driver = $request->user()->driver;

        if (! $driver) {
            return response()->json(['message' => 'Driver profile not found.'], 404);
        }

        return response()->json(['driver' => $driver->load('vehicle', 'documents')]);
    }

    public function uploadDocument(Request $request): JsonResponse
    {
        $driver = $request->user()->driver;

        if (! $driver) {
            return response()->json(['message' => 'Driver profile not found.'], 404);
        }

        $validated = $request->validate([
            'type' => ['required', Rule::enum(DocumentType::class)],
            'document' => ['required', 'file', 'mimes:jpg,jpeg,png,pdf', 'max:5120'],
        ]);

        $file = $request->file('document');
        $path = $file->store("driver-documents/{$driver->id}", 'public');

        $document = DriverDocument::query()->updateOrCreate(
            [
                'driver_id' => $driver->id,
                'type' => $validated['type'],
            ],
            [
                'file_path' => $path,
                'original_name' => $file->getClientOriginalName(),
                'status' => 'pending',
                'rejection_reason' => null,
                'verified_at' => null,
            ],
        );

        if (in_array($driver->approval_status, [
            DriverApprovalStatus::Rejected,
            DriverApprovalStatus::Approved,
        ], true)) {
            $wasApproved = $driver->approval_status === DriverApprovalStatus::Approved;
            $driver->update([
                'approval_status' => DriverApprovalStatus::Pending,
                'is_online' => false,
                'rejection_reason' => $wasApproved
                    ? 'Belge güncellendi; yeniden inceleme gerekir.'
                    : null,
                'approved_at' => null,
            ]);
        }

        return response()->json([
            'message' => 'Document uploaded successfully.',
            'document' => $document,
        ]);
    }

    public function goOnline(Request $request): JsonResponse
    {
        $driver = $this->getApprovedDriver($request);

        if ($driver instanceof JsonResponse) {
            return $driver;
        }

        $validated = $request->validate([
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'heading' => ['sometimes', 'nullable', 'numeric'],
        ]);

        $this->matchingService->updateDriverLocation(
            $driver,
            $validated['latitude'],
            $validated['longitude'],
            $validated['heading'] ?? null,
        );

        $driver->update(['is_online' => true]);

        $this->rtdbService->syncDriverLocation(
            $driver->id,
            $validated['latitude'],
            $validated['longitude'],
            $validated['heading'] ?? null,
        );

        return response()->json([
            'message' => 'You are now online.',
            'driver' => $driver->fresh(),
        ]);
    }

    public function goOffline(Request $request): JsonResponse
    {
        $driver = $request->user()->driver;

        if (! $driver) {
            return response()->json(['message' => 'Driver profile not found.'], 404);
        }

        $driver->update(['is_online' => false]);

        return response()->json([
            'message' => 'You are now offline.',
            'driver' => $driver->fresh(),
        ]);
    }

    public function updateLocation(Request $request): JsonResponse
    {
        $driver = $this->getApprovedDriver($request);

        if ($driver instanceof JsonResponse) {
            return $driver;
        }

        $validated = $request->validate([
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'heading' => ['sometimes', 'nullable', 'numeric'],
        ]);

        $this->matchingService->updateDriverLocation(
            $driver,
            $validated['latitude'],
            $validated['longitude'],
            $validated['heading'] ?? null,
        );

        if ($driver->is_online) {
            $this->rtdbService->syncDriverLocation(
                $driver->id,
                $validated['latitude'],
                $validated['longitude'],
                $validated['heading'] ?? null,
            );
        }

        return response()->json([
            'message' => 'Location updated.',
            'driver' => $driver->fresh(),
        ]);
    }

    protected function getApprovedDriver(Request $request): Driver|JsonResponse
    {
        $driver = $request->user()->driver;

        if (! $driver) {
            return response()->json(['message' => 'Driver profile not found.'], 404);
        }

        if (! $driver->isApproved()) {
            return response()->json(['message' => 'Driver account is not approved.'], 403);
        }

        return $driver;
    }
}
