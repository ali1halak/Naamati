<?php

namespace App\Http\Resources;

use App\Support\ArabicDate;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * One card on the charity's marketplace screen.
 *
 * Trimmed on purpose: this is the list a charity scrolls before choosing, so
 * it carries what answers "should we drive out for this?" and nothing more.
 * The donor's phone number in particular is withheld until a charity has
 * actually accepted the request — see DonationRequestResource for that view.
 *
 * Expects foodCategory and images to be eager loaded.
 */
class CharityOrderResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id'          => $this->id,
            'title'       => $this->foodCategory?->name_ar,
            'description' => $this->description ?: $this->quantity_desc,

            // First photo for the card; the rest are on the details screen.
            'image_url' => $this->whenLoaded('images', fn () => $this->images->first()?->url),
            'images'    => $this->whenLoaded('images', fn () => $this->images->pluck('url')),

            'category_icon' => $this->foodCategory?->icon,
            'quantity_desc' => $this->quantity_desc,

            // Drives the kitchen rule: a charity without one never sees these,
            // but the badge still matters on the card.
            'needs_cooking' => $this->needs_cooking,

            'expiry_date'     => $this->valid_until?->toDateString(),
            'pickup_deadline' => ArabicDate::timeArabic($this->pickup_until),

            // Raw values too, so the app can sort or count down without
            // parsing the Arabic strings above.
            'valid_until_iso'  => $this->valid_until,
            'pickup_until_iso' => $this->pickup_until,

            'location_zone' => $this->pickup_address,
            'latitude'      => $this->latitude,
            'longitude'     => $this->longitude,

            'created_at'       => $this->created_at,
            'created_at_label' => ArabicDate::day($this->created_at),
        ];
    }
}
