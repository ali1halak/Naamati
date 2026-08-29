<?php

namespace App\Models;

use App\Enums\NotificationType;
use App\Enums\RecipientType;
use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    protected $fillable = [
        'recipient_type', 'recipient_id', 'type', 'payload', 'is_read', 'donation_request_id',
    ];

    protected $casts = [
        'recipient_type' => RecipientType::class,
        'type'           => NotificationType::class,
        'payload'        => 'array',
        'is_read'        => 'boolean',
    ];

    public function donationRequest()
    {
        return $this->belongsTo(DonationRequest::class);
    }
}
