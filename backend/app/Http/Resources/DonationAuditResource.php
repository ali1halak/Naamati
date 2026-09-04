<?php

namespace App\Http\Resources;

use App\Enums\RequestStatus;
use App\Support\ArabicDate;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * The audit view of one donation, grouped the way the screen reads it:
 * what was given, how it travelled, and who it reached.
 *
 * Grouped rather than flat on purpose — the screen renders three separate
 * cards, and a flat payload would make the app rebuild these groupings itself.
 *
 * Expects charity, foodCategory, distribution and rating to be eager loaded.
 */
class DonationAuditResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'order_info' => [
                'order_number'  => '#' . $this->id,
                'title'         => $this->foodCategory?->name_ar,
                'status'        => $this->status->value,
                'status_label'  => $this->status->detailedLabel(),
                'food_type'     => $this->foodCategory?->name_ar,
                'food_condition' => $this->needs_cooking ? 'نيء' : 'جاهز للتوزيع',
                'expiry_date'   => $this->valid_until?->toDateString(),
                'quantity_desc' => $this->quantity_desc,
                'description'   => $this->description,
            ],

            'logistics_details' => [
                'charity_id'     => $this->charity_id,
                'charity_name'   => $this->charity?->name,
                'pickup_address' => $this->pickup_address,

                // Times for the screen, plus the raw ISO values so the app can
                // sort or recompute without parsing Arabic.
                'submitted_at'  => ArabicDate::time($this->created_at),
                'accepted_at'   => ArabicDate::time($this->accepted_at),
                'picked_up_at'  => ArabicDate::time($this->picked_up_at),
                'completed_at'  => ArabicDate::time($this->completed_at),
                'submitted_at_iso' => $this->created_at,
                'accepted_at_iso'  => $this->accepted_at,
                'picked_up_at_iso' => $this->picked_up_at,
                'completed_at_iso' => $this->completed_at,
            ],

            // null until the charity files its numbers — the screen should hide
            // the impact card rather than render zeros.
            'social_impact' => $this->distribution ? [
                'beneficiary_families'    => $this->distribution->families_count,
                'beneficiary_individuals' => $this->distribution->individuals_count,
                'distribution_zone'       => $this->distribution->area,
                'notes'                   => $this->distribution->notes,
                'distributed_at'          => ArabicDate::dayTime($this->distribution->distributed_at),
            ] : null,

            'rating' => new RatingResource($this->whenLoaded('rating')),

            // Mirrors RatingService: from handover onward, and only once.
            'can_rate_charity' => in_array($this->status, [RequestStatus::PickedUp, RequestStatus::Completed], true)
                && $this->charity_id !== null
                && $this->rating === null,
        ];
    }
}
