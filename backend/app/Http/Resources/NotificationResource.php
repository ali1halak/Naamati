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
            // An empty PHP array (no payload data) encodes as JSON `[]`, but
            // the client always expects an object — casting forces `{}`.
            'payload'             => (object) $this->payload,
            'is_read'             => $this->is_read,
            'donation_request_id' => $this->donation_request_id,
            'created_at'          => $this->created_at,
        ];
    }
}
