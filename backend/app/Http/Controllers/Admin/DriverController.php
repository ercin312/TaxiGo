<?php

namespace App\Http\Controllers\Admin;

use App\Enums\DriverApprovalStatus;
use App\Http\Controllers\Controller;
use App\Models\Driver;
use App\Models\DriverDocument;
use App\Services\DriverDocumentReviewService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Inertia\Inertia;
use Inertia\Response;

class DriverController extends Controller
{
    public function __construct(
        protected DriverDocumentReviewService $documents,
    ) {}

    public function index(Request $request): Response
    {
        $drivers = Driver::query()
            ->with(['user', 'vehicle'])
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
            ->paginate(20)
            ->withQueryString();

        return Inertia::render('Admin/Drivers/Index', [
            'drivers' => $drivers,
            'filters' => $request->only(['search', 'status']),
            'statuses' => array_column(DriverApprovalStatus::cases(), 'value'),
        ]);
    }

    public function show(Driver $driver): Response
    {
        $driver->load('user', 'vehicle', 'documents', 'rides');

        return Inertia::render('Admin/Drivers/Show', [
            'driver' => $driver,
            'document_review' => [
                'required_count' => count($this->documents->requiredTypes()),
                'uploaded_count' => $driver->documents->count(),
                'all_uploaded' => $this->documents->hasAllRequiredDocuments($driver),
                'all_verified' => $this->documents->allDocumentsVerified($driver),
                'can_force_approve' => request()->user()?->isSuperAdmin() ?? false,
            ],
        ]);
    }

    public function approve(Request $request, Driver $driver): RedirectResponse
    {
        $force = $request->boolean('force') && $request->user()?->isSuperAdmin();

        try {
            $this->documents->assertCanApprove($driver, force: $force);
        } catch (ValidationException $e) {
            return back()->withErrors($e->errors());
        }

        $driver->update([
            'approval_status' => DriverApprovalStatus::Approved,
            'approved_at' => now(),
            'rejection_reason' => null,
        ]);

        return back()->with(
            'success',
            $force
                ? 'Sürücü süper admin tarafından zorla onaylandı.'
                : 'Sürücü onaylandı.',
        );
    }

    public function reject(Request $request, Driver $driver): RedirectResponse
    {
        $validated = $request->validate([
            'rejection_reason' => ['required', 'string', 'max:1000'],
        ]);

        $driver->update([
            'approval_status' => DriverApprovalStatus::Rejected,
            'rejection_reason' => $validated['rejection_reason'],
            'is_online' => false,
        ]);

        return back()->with('success', 'Sürücü reddedildi.');
    }

    public function ban(Request $request, Driver $driver): RedirectResponse
    {
        $validated = $request->validate([
            'rejection_reason' => ['required', 'string', 'max:1000'],
        ]);

        $driver->update([
            'approval_status' => DriverApprovalStatus::Banned,
            'rejection_reason' => $validated['rejection_reason'],
            'is_online' => false,
        ]);

        $driver->user->update(['is_active' => false]);

        return back()->with('success', 'Sürücü yasaklandı.');
    }

    public function verifyDocument(Driver $driver, DriverDocument $document): RedirectResponse
    {
        abort_unless($document->driver_id === $driver->id, 404);
        $this->documents->verify($document);

        return back()->with('success', 'Belge doğrulandı.');
    }

    public function rejectDocument(Request $request, Driver $driver, DriverDocument $document): RedirectResponse
    {
        abort_unless($document->driver_id === $driver->id, 404);

        $validated = $request->validate([
            'rejection_reason' => ['required', 'string', 'max:1000'],
        ]);

        $this->documents->reject($document, $validated['rejection_reason']);

        return back()->with('success', 'Belge reddedildi.');
    }
}
