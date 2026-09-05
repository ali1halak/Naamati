<?php

namespace App\Services;

use App\Enums\RequestStatus;
use App\Models\DonationRequest;
use App\Models\Rating;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class RatingService
{
    /**
     * The donor rates the charity once the food has actually changed hands.
     *
     * Allowed from picked_up onward: the donor's part of the exchange is over
     * at handover, so they should not have to wait for the charity to file its
     * distribution paperwork before they can leave feedback.
     */
    public function rate(DonationRequest $request, array $data): Rating
    {
        if (! in_array($request->status, [RequestStatus::PickedUp, RequestStatus::Completed], true)) {
            throw ValidationException::withMessages([
                'status' => 'لا يمكن التقييم إلا بعد تأكيد تسليم الطعام.',
            ]);
        }

        if (! $request->charity_id) {
            throw ValidationException::withMessages([
                'status' => 'لا توجد جمعية مرتبطة بهذا التبرع لتقييمها.',
            ]);
        }

        return DB::transaction(function () use ($request, $data) {
            $rating = Rating::create([
                'donation_request_id' => $request->id,
                'stars'               => $data['stars'],
                'comment'             => $data['comment'] ?? null,
            ]);

            $this->refreshCharityAverage($request->charity_id);

            return $rating;
        });
    }

    /**
     * Recompute the stored average from scratch rather than nudging it, so the
     * cached value can never drift away from the underlying rows.
     */
    private function refreshCharityAverage(int $charityId): void
    {
        $stats = DB::table('ratings')
            ->join('donation_requests', 'ratings.donation_request_id', '=', 'donation_requests.id')
            ->where('donation_requests.charity_id', $charityId)
            ->selectRaw('AVG(ratings.stars) AS avg_stars, COUNT(*) AS total')
            ->first();

        DB::table('charities')->where('id', $charityId)->update([
            'rating_avg'    => $stats->total ? round((float) $stats->avg_stars, 2) : null,
            'ratings_count' => (int) $stats->total,
            'updated_at'    => now(),
        ]);
    }
}
