<?php

namespace App\Services;

use App\Enums\CharityStatus;
use App\Models\Charity;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class CharityService
{
    /**
     * List charities for the admin, newest first, optionally filtered by status.
     */
    public function list(?string $status = null): LengthAwarePaginator
    {
        return Charity::query()
            ->when($status, fn ($q) => $q->where('status', $status))
            ->withCount('strikes')
            ->latest()
            ->paginate(15);
    }

    /**
     * Approve a charity so it can start using charity features.
     * Also used to reinstate a suspended charity, which clears its strikes so
     * it does not get re-suspended by the next single no-show.
     */
    public function approve(Charity $charity): Charity
    {
        if ($charity->status === CharityStatus::Suspended) {
            $charity->strikes()->delete();
        }

        $charity->update(['status' => CharityStatus::Active]);

        return $charity->refresh();
    }

    public function suspend(Charity $charity): Charity
    {
        $charity->update(['status' => CharityStatus::Suspended]);

        return $charity->refresh();
    }
}
