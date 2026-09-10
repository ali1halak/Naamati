<?php

namespace App\Http\Resources;

use App\Enums\RequestStatus;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * A charity's own full profile — the richer counterpart of
 * `CharityCardResource` (which is deliberately trimmed for the donor's eyes).
 */
class CharityProfileResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id'          => $this->id,
            'name'        => $this->name,
            'email'       => $this->email,
            'phone'       => $this->phone,
            'address'     => $this->address,
            'latitude'    => $this->latitude,
            'longitude'   => $this->longitude,
            // The `time` column comes back from MySQL as "H:i:s" — trimmed to
            // "H:i" so it round-trips straight into the edit form's picker
            // text and back through UpdateProfileRequest's date_format:H:i
            // rule without the admin/charity having to touch it.
            'work_start'  => substr($this->work_start, 0, 5),
            'work_end'    => substr($this->work_end, 0, 5),
            'has_kitchen' => $this->has_kitchen,

            'status'       => $this->status->value,
            'status_label' => $this->status->label(),

            'logo_url' => $this->logo_url,

            // null until the first rating lands — the app should show
            // "no ratings yet" rather than a misleading zero.
            'rating_avg'    => $this->rating_avg,
            'ratings_count' => $this->ratings_count,

            'completed_donations_count' => $this->whenCounted(
                'donationRequests',
                fn () => $this->donation_requests_count,
                $this->donationRequests()->where('status', RequestStatus::Completed)->count()
            ),

            'member_since' => $this->created_at?->toDateString(),
            'created_at'   => $this->created_at,
        ];
    }
}
