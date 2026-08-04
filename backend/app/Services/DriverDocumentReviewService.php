<?php

namespace App\Services;

use App\Enums\DocumentType;
use App\Enums\DriverApprovalStatus;
use App\Models\Driver;
use App\Models\DriverDocument;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class DriverDocumentReviewService
{
    /**
     * Required document types for taxi mode approval.
     *
     * @return list<DocumentType>
     */
    public function requiredTypes(): array
    {
        return DocumentType::cases();
    }

    public function hasAllRequiredDocuments(Driver $driver): bool
    {
        $uploaded = $driver->documents()
            ->pluck('type')
            ->map(fn ($type) => $type instanceof DocumentType ? $type->value : (string) $type)
            ->all();

        foreach ($this->requiredTypes() as $type) {
            if (! in_array($type->value, $uploaded, true)) {
                return false;
            }
        }

        return true;
    }

    public function allDocumentsVerified(Driver $driver): bool
    {
        if (! $this->hasAllRequiredDocuments($driver)) {
            return false;
        }

        return $driver->documents()
            ->whereIn('type', array_map(fn (DocumentType $t) => $t->value, $this->requiredTypes()))
            ->where('status', '!=', 'verified')
            ->doesntExist();
    }

    public function verify(DriverDocument $document): DriverDocument
    {
        $document->update([
            'status' => 'verified',
            'rejection_reason' => null,
            'verified_at' => now(),
        ]);

        return $document->fresh();
    }

    public function reject(DriverDocument $document, string $reason): DriverDocument
    {
        $document->update([
            'status' => 'rejected',
            'rejection_reason' => $reason,
            'verified_at' => null,
        ]);

        // Driver must re-submit; keep overall status pending if was pending.
        $driver = $document->driver;
        if ($driver && $driver->approval_status === DriverApprovalStatus::Approved) {
            $driver->update([
                'approval_status' => DriverApprovalStatus::Pending,
                'is_online' => false,
                'rejection_reason' => 'Belge yeniden inceleme gerektiriyor.',
            ]);
        }

        return $document->fresh();
    }

    /**
     * @throws ValidationException
     */
    public function assertCanApprove(Driver $driver, bool $force = false): void
    {
        $driver->loadMissing('documents');

        if ($force) {
            return;
        }

        if (! $this->hasAllRequiredDocuments($driver)) {
            throw ValidationException::withMessages([
                'documents' => ['Tüm zorunlu belgeler yüklenmeden sürücü onaylanamaz.'],
            ]);
        }

        if (! $this->allDocumentsVerified($driver)) {
            throw ValidationException::withMessages([
                'documents' => ['Tüm belgeler doğrulanmadan sürücü onaylanamaz. (Süper admin zorla onaylayabilir.)'],
            ]);
        }
    }

    public function documentPublicUrl(?string $path): ?string
    {
        if ($path === null || $path === '') {
            return null;
        }

        return Storage::disk('public')->url($path);
    }
}
