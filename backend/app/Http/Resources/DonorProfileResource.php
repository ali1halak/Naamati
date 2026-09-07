<?php

namespace App\Http\Resources;

use App\Enums\RequestStatus;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * A donor's own full profile — richer than what's embedded elsewhere
 * (nothing today embeds a donor at all; the charity only ever sees the
 * donor's name/phone via `DonationRequestResource`).
 */
class DonorProfileResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id'          => $this->id,
            'name'        => $this->name,
            'email'       => $this->email,
            'phone'       => $this->phone,
            'type'        => $this->type?->value,
            'avatar_url'  => $this->avatar_url,

            // How many donations this donor has actually seen through.
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
