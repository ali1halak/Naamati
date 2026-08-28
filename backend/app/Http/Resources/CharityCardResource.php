<?php

namespace App\Http\Resources;

use App\Enums\RequestStatus;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * The charity as the donor sees it on the "accepted" screen — enough to decide
 * you are comfortable handing your food over, and nothing more. Deliberately
 * not the full charity record: no email, no status, no work hours.
 */
class CharityCardResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id'       => $this->id,
            'name'     => $this->name,
            'phone'    => $this->phone,
            'address'  => $this->address,
            'logo_url' => $this->logo_url,

            // null until the first rating lands — the app should show
            // "no ratings yet" rather than a misleading zero.
            'rating_avg'    => $this->rating_avg,
            'ratings_count' => $this->ratings_count,

            // How many donations this charity has actually seen through.
            'completed_donations_count' => $this->whenCounted(
                'donationRequests',
                fn () => $this->donation_requests_count,
                $this->donationRequests()->where('status', RequestStatus::Completed)->count()
            ),
        ];
    }
}
