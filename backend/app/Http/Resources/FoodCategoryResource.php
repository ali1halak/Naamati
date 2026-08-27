<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class FoodCategoryResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id'      => $this->id,
            'name_ar' => $this->name_ar,
            'name_en' => $this->name_en,

            // What the form should pre-tick for "needs cooking". The donor can
            // still override it per request.
            'default_needs_cooking' => $this->default_needs_cooking,
        ];
    }
}
