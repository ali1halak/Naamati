<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

/**
 * A donation request as both sides see it.
 *
 * qr_token is never included here — it is returned exactly once, in the
 * response to the charity's accept call, so it cannot leak through a listing.
 */
class DonationRequestResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id'     => $this->id,
            'status' => $this->status->value,

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

            'accepted_at'   => $this->accepted_at,
            'picked_up_at'  => $this->picked_up_at,
            'cancel_reason' => $this->cancel_reason,
            'created_at'    => $this->created_at,

            'distribution' => new DistributionResource($this->whenLoaded('distribution')),
            'rating'       => new RatingResource($this->whenLoaded('rating')),
        ];
    }
}
