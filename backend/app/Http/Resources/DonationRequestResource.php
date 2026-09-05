<?php

namespace App\Http\Resources;

use App\Support\ArabicDate;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * A donation request as both sides see it.
 */
class DonationRequestResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id'     => $this->id,
            'status' => $this->status->value,

            // Ready-to-render fields for the history list, so the app does not
            // reimplement the wording. `status` above stays the machine value.
            'status_label'     => $this->status->label(),
            'title'            => $this->whenLoaded('foodCategory', fn () => $this->foodCategory->name_ar),
            'category_icon'    => $this->whenLoaded('foodCategory', fn () => $this->foodCategory->icon),
            'created_at_label' => ArabicDate::day($this->created_at),

            'food_category' => new FoodCategoryResource($this->whenLoaded('foodCategory')),
            'needs_cooking' => $this->needs_cooking,
            'quantity_desc' => $this->quantity_desc,
            'description'   => $this->description,

            'valid_until'  => $this->valid_until,
            'pickup_until' => $this->pickup_until,

            'pickup_address' => $this->pickup_address,
            // Optional map pin — null when the donor only typed an address.
            'latitude'       => $this->latitude,
            'longitude'      => $this->longitude,
            'contact_phone'  => $this->contact_phone,

            // Present only once a charity has taken the request.
            'charity'     => new CharityCardResource($this->whenLoaded('charity')),
            'eta_minutes' => $this->eta_minutes,

            // Photos of the food, ordered as the donor uploaded them.
            'images'    => $this->whenLoaded('images', fn () => $this->images->pluck('url')),
            'image_url' => $this->whenLoaded('images', fn () => $this->images->first()?->url),

            'accepted_at' => $this->accepted_at,

            // Both halves of the handover, so each app can show whether it is
            // still waiting on the other side.
            'donor_confirmed_at'   => $this->donor_confirmed_at,
            'charity_confirmed_at' => $this->charity_confirmed_at,
            'picked_up_at'         => $this->picked_up_at,
            'completed_at'         => $this->completed_at,
            'cancel_reason' => $this->cancel_reason,
            'created_at'    => $this->created_at,

            'distribution' => new DistributionResource($this->whenLoaded('distribution')),
            'rating'       => new RatingResource($this->whenLoaded('rating')),
        ];
    }
}
