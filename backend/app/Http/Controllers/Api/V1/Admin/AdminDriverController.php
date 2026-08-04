<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Enums\DriverApprovalStatus;
use App\Http\Controllers\Controller;
use App\Models\Driver;
use App\Models\DriverDocument;
use App\Services\DriverDocumentReviewService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class AdminDriverController extends Controller
{
    public function __construct(
        protected DriverDocumentReviewService $documents,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $drivers = Driver::query()
            ->with(['user:id,name,email,phone,is_active', 'vehicle'])
            ->withCount([
                'documents',
                'documents as verified_documents_count' => fn ($q) => $q->where('status', 'verified'),
            ])
            ->when($request->status, fn ($q, $status) => $q->where('approval_status', $status))
            ->when($request->search, function ($query, $search) {
                $query->whereHas('user', function ($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%")
                        ->orWhere('phone', 'like', "%{$search}%");
                });
            })
            ->latest()
            ->paginate(min((int) $request->get('per_page', 30), 100));

        return response()->json($drivers);
    }

    public function show(Driver $driver): JsonResponse
    {
        $driver->load(['user:id,name,email,phone,is_active', 'vehicle', 'documents']);

        $docs = $driver->documents->map(function (DriverDocument $doc) {
            return [
                'id' => $doc->id,
                'type' => $doc->type?->value ?? $doc->type,
                'type_label' => $doc->type?->label() ?? (string) $doc->type,
                'original_name' => $doc->original_name,
                'status' => $doc->status,
                'rejection_reason' => $doc->rejection_reason,
                'verified_at' => $doc->verified_at,
                'file_url' => $this->documents->documentPublicUrl($doc->file_path),
                'file_path' => $doc->file_path,
            ];
        });

        return response()->json([
            'driver' => $driver,
            'documents' => $docs,
            'document_review' => [
                'required_count' => count($this->documents->requiredTypes()),
                'uploaded_count' => $driver->documents->count(),
                'all_uploaded' => $this->documents->hasAllRequiredDocuments($driver),
                'all_verified' => $this->documents->allDocumentsVerified($driver),
                'can_force_approve' => request()->user()?->isSuperAdmin() ?? false,
            ],
        ]);
    }

    public function approve(Request $request, Driver $driver): JsonResponse
    {
        $force = $request->boolean('force') && $request->user()?->isSuperAdmin();

        try {
            $this->documents->assertCanApprove($driver, force: $force);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => collect($e->errors())->flatten()->first() ?? 'Onaylanamadı.',
                'errors' => $e->errors(),
            ], 422);
        }

        $driver->update([
            'approval_status' => DriverApprovalStatus::Approved,
            'approved_at' => now(),
            'rejection_reason' => null,
        ]);

        return response()->json([
            'message' => $force
                ? 'Sürücü süper admin tarafından zorla onaylandı.'
                : 'Sürücü onaylandı.',
            'driver' => $driver->fresh(['user', 'vehicle', 'documents']),
        ]);
    }

    public function reject(Request $request, Driver $driver): JsonResponse
    {
        $validated = $request->validate([
            'rejection_reason' => ['required', 'string', 'max:1000'],
        ]);

        $driver->update([
            'approval_status' => DriverApprovalStatus::Rejected,
            'rejection_reason' => $validated['rejection_reason'],
            'is_online' => false,
        ]);

        return response()->json([
            'message' => 'Sürücü reddedildi.',
            'driver' => $driver->fresh(['user', 'vehicle']),
        ]);
    }

    public function ban(Request $request, Driver $driver): JsonResponse
    {
        $validated = $request->validate([
            'rejection_reason' => ['required', 'string', 'max:1000'],
        ]);

        $driver->update([
            'approval_status' => DriverApprovalStatus::Banned,
            'rejection_reason' => $validated['rejection_reason'],
            'is_online' => false,
        ]);
        $driver->user?->update(['is_active' => false]);

        return response()->json([
            'message' => 'Sürücü yasaklandı.',
            'driver' => $driver->fresh(['user', 'vehicle']),
        ]);
    }

    public function verifyDocument(Driver $driver, DriverDocument $document): JsonResponse
    {
        abort_unless($document->driver_id === $driver->id, 404);

        $document = $this->documents->verify($document);

        return response()->json([
            'message' => 'Belge doğrulandı.',
            'document' => $document,
            'document_review' => [
                'all_uploaded' => $this->documents->hasAllRequiredDocuments($driver->fresh()),
                'all_verified' => $this->documents->allDocumentsVerified($driver->fresh()),
            ],
        ]);
    }

    public function rejectDocument(Request $request, Driver $driver, DriverDocument $document): JsonResponse
    {
        abort_unless($document->driver_id === $driver->id, 404);

        $validated = $request->validate([
            'rejection_reason' => ['required', 'string', 'max:1000'],
        ]);

        $document = $this->documents->reject($document, $validated['rejection_reason']);

        return response()->json([
            'message' => 'Belge reddedildi.',
            'document' => $document,
            'driver' => $driver->fresh(['user', 'vehicle', 'documents']),
        ]);
    }
}
