<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class RatingResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id'         => $this->id,
            'stars'      => $this->stars,
            'comment'    => $this->comment,
            'created_at' => $this->created_at,
        ];
    }
}
