<?php

namespace App\Models;

use App\Enums\StrikeReason;
use Illuminate\Database\Eloquent\Model;

class Strike extends Model
{
    protected $fillable = ['charity_id', 'donation_request_id', 'reason', 'note'];

    protected function casts(): array
    {
        return [
            'reason' => StrikeReason::class,
        ];
    }

    public function charity()
    {
        return $this->belongsTo(Charity::class);
    }

    public function donationRequest()
    {
        return $this->belongsTo(DonationRequest::class);
    }
}