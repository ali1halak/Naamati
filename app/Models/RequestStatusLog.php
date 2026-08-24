<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RequestStatusLog extends Model
{
    public $timestamps = false; // only created_at, set via useCurrent() in migration

    protected $fillable = ['donation_request_id', 'from_status', 'to_status', 'note'];

    public function donationRequest()
    {
        return $this->belongsTo(DonationRequest::class);
    }
}