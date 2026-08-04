<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Complaint;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class ComplaintController extends Controller
{
    public function index(Request $request): Response
    {
        $complaints = Complaint::query()
            ->with(['user', 'ride'])
            ->when($request->status, fn ($q, $status) => $q->where('status', $status))
            ->latest()
            ->paginate(20)
            ->withQueryString();

        return Inertia::render('Admin/Complaints/Index', [
            'complaints' => $complaints,
            'filters' => $request->only(['status']),
        ]);
    }

    public function show(Complaint $complaint): Response
    {
        return Inertia::render('Admin/Complaints/Show', [
            'complaint' => $complaint->load(['user', 'ride.driver.user']),
        ]);
    }

    public function update(Request $request, Complaint $complaint): RedirectResponse
    {
        $validated = $request->validate([
            'status' => ['required', 'in:open,in_progress,resolved,closed,urgent'],
            'admin_response' => ['sometimes', 'nullable', 'string', 'max:5000'],
        ]);

        $complaint->update([
            ...$validated,
            'resolved_at' => in_array($validated['status'], ['resolved', 'closed']) ? now() : null,
        ]);

        return back()->with('success', 'Complaint updated successfully.');
    }
}
