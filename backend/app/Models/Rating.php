<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Rating extends Model
{
    protected $fillable = ['donation_request_id', 'stars', 'comment'];

    public function donationRequest()
    {
        return $this->belongsTo(DonationRequest::class);
    }
}