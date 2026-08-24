<?php

namespace App\Models;

use App\Enums\RequestStatus;
use Illuminate\Database\Eloquent\Model;

class DonationRequest extends Model
{
    protected $fillable = [
        'donor_id', 'charity_id', 'food_category_id', 'needs_cooking', 'description',
        'valid_until', 'pickup_until', 'pickup_address', 'contact_phone', 'status',
        'qr_token', 'accepted_at', 'picked_up_at', 'confirmed_at',
    ];

    protected $hidden = ['qr_token']; // never exposed in listings

    protected function casts(): array
    {
        return [
            'needs_cooking' => 'boolean',
            'status'        => RequestStatus::class,
            'valid_until'   => 'datetime',
            'pickup_until'  => 'datetime',
            'accepted_at'   => 'datetime',
            'picked_up_at'  => 'datetime',
            'confirmed_at'  => 'datetime',
        ];
    }

    public function donor()
    {
        return $this->belongsTo(Donor::class);
    }

    public function charity()
    {
        return $this->belongsTo(Charity::class);
    }

    public function foodCategory()
    {
        return $this->belongsTo(FoodCategory::class);
    }

    public function distribution()
    {
        return $this->hasOne(Distribution::class);
    }

    public function rating()
    {
        return $this->hasOne(Rating::class);
    }

    public function strikes()
    {
        return $this->hasMany(Strike::class);
    }

    public function statusLogs()
    {
        return $this->hasMany(RequestStatusLog::class);
    }
}