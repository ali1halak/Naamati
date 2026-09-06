<?php

namespace App\Http\Resources;

use App\Support\ArabicDate;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * One card on the charity's سجل المخالفات screen.
 */
class ViolationResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            // Reference the charity can quote back to an admin.
            'reference' => 'VIO-' . str_pad((string) $this->id, 4, '0', STR_PAD_LEFT),
            'id'        => $this->id,

            'type'  => $this->reason->value,
            'title' => $this->reason->label(),

            'severity'       => $this->severity->value,
            'severity_label' => $this->severity->label(),

            // The admin's own words, shown to the charity as written.
            'admin_note' => $this->admin_note,

            // Which order it came from, when it came from one at all.
            'donation_request_id' => $this->donation_request_id,

            'date'       => ArabicDate::day($this->created_at),
            'created_at' => $this->created_at,
        ];
    }
}
