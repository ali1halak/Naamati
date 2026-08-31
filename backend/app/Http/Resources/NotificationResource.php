<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class NotificationResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id'                  => $this->id,
            'type'                => $this->type->value,
            'recipient_type'      => $this->recipient_type->value,
            'recipient_id'        => $this->recipient_id,
            'payload'             => $this->payload,
            'is_read'             => $this->is_read,
            'donation_request_id' => $this->donation_request_id,
            'created_at'          => $this->created_at,
        ];
    }
}
