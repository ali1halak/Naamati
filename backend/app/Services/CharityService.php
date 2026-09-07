<?php

namespace App\Services;

use App\Enums\CharityStatus;
use App\Models\Charity;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class CharityService
{
    public function __construct(private readonly NotificationService $notifications)
    {
    }

    /**
     * List charities for the admin, newest first, optionally filtered by status.
     */
    public function list(?string $status = null): LengthAwarePaginator
    {
        return Charity::query()
            ->when($status, fn ($q) => $q->where('status', $status))
            ->withCount('violations')
            ->latest()
            ->paginate(15);
    }

    /**
     * Approve a charity so it can start using charity features.
     * Also used to reinstate a suspended charity, which clears its violations
     * so the same record cannot suspend it a second time.
     */
    public function approve(Charity $charity): Charity
    {
        if ($charity->status === CharityStatus::Suspended) {
            $charity->violations()->delete();
        }

        $charity->update(['status' => CharityStatus::Active]);
        $charity->refresh();
        $this->notifications->charityStatusChanged($charity, approved: true);

        return $charity;
    }

    public function suspend(Charity $charity): Charity
    {
        $charity->update(['status' => CharityStatus::Suspended]);
        $charity->refresh();
        $this->notifications->charityStatusChanged($charity, approved: false);

        return $charity;
    }
}
