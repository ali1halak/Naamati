<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

/**
 * The real numbers the charity reported after handing the food out.
 * Aggregate counts only — no beneficiary identities are ever stored.
 */
class DistributionResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id'                => $this->id,
            'families_count'    => $this->families_count,
            'individuals_count' => $this->individuals_count,
            'area'              => $this->area,
            'distributed_at'    => $this->distributed_at,
        ];
    }
}
