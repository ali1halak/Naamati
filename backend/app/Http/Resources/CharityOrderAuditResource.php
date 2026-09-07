<?php

namespace App\Http\Resources;

use App\Support\ArabicDate;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * The charity's audit view of one order it handled.
 *
 * Grouped the way the screen reads — item, pickup, impact — so the app renders
 * three cards without regrouping a flat payload itself. The donor's counterpart
 * is DonationAuditResource; this one leans on the charity's side of the story
 * and adds the donor's name and contact, which the charity has earned by
 * accepting the request.
 *
 * Expects donor, foodCategory, distribution and images to be eager loaded.
 */
class CharityOrderAuditResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            // Quotable reference; `id` stays for anything that needs the key.
            'order_id' => sprintf('REQ-%s-%03d', $this->created_at?->format('Y-m'), $this->id),
            'id'       => $this->id,

            'status'       => $this->status->value,
            'status_label' => $this->status->label(),

            'donor' => [
                'name'  => $this->donor?->name,
                // The donor chose this number for pickup coordination.
                'phone' => $this->contact_phone,
            ],

            'donation' => [
                'category'       => $this->foodCategory?->name_ar,
                'category_icon'  => $this->foodCategory?->icon,
                'food_type'      => $this->foodCategory?->name_ar,
                'food_condition' => $this->needs_cooking ? 'نيء' : 'جاهز للتوزيع',
                'quantity'        => $this->quantity,
                'description'    => $this->description,
                'expiry_date'    => $this->valid_until?->toDateString(),
                'created_at'     => ArabicDate::dayTime($this->created_at),
                'created_at_iso' => $this->created_at,
                'images'         => $this->whenLoaded('images', fn () => $this->images->pluck('url')),
            ],

            'pickup' => [
                'accepted_at'      => ArabicDate::dayTime($this->accepted_at),
                'actual_pickup_at' => ArabicDate::dayTime($this->picked_up_at),
                'deadline'         => ArabicDate::dayTime($this->pickup_until),
                'location'         => $this->pickup_address,
                'latitude'         => $this->latitude,
                'longitude'        => $this->longitude,
                'notes'            => $this->pickup_notes,
                'eta_minutes'      => $this->eta_minutes,

                // Raw values so the app can build a timeline without parsing Arabic.
                'accepted_at_iso'      => $this->accepted_at,
                'actual_pickup_at_iso' => $this->picked_up_at,
                'completed_at_iso'     => $this->completed_at,
            ],

            // null until the charity files its numbers — the screen should hide
            // the impact card rather than render zeros.
            'distribution' => $this->distribution ? [
                'beneficiary_families'    => $this->distribution->families_count,
                'beneficiary_individuals' => $this->distribution->individuals_count,
                'distribution_zone'       => $this->distribution->area,
                'notes'                   => $this->distribution->notes,
                'distributed_at'          => ArabicDate::dayTime($this->distribution->distributed_at),
            ] : null,

            'cancel_reason' => $this->cancel_reason,
        ];
    }
}
