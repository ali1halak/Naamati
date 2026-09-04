<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Distribution extends Model
{
    protected $fillable = [
        'donation_request_id', 'families_count', 'individuals_count',
        'area', 'notes', 'distributed_at',
    ];

    protected function casts(): array
    {
        return [
            'distributed_at' => 'datetime',
        ];
    }

    public function donationRequest()
    {
        return $this->belongsTo(DonationRequest::class);
    }
}