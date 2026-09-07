<?php

namespace App\Models;

use App\Enums\CancelledBy;
use App\Enums\RequestStatus;
use Illuminate\Database\Eloquent\Model;

class DonationRequest extends Model
{
    protected $fillable = [
        'donor_id', 'charity_id', 'food_category_id', 'needs_cooking', 'quantity',
        'description', 'custom_category', 'valid_until', 'pickup_until', 'pickup_address',
        'pickup_notes', 'latitude', 'longitude', 'contact_phone', 'status', 'accepted_at',
        'eta_minutes', 'picked_up_at', 'donor_confirmed_at', 'charity_confirmed_at',
        'completed_at', 'cancel_reason', 'cancelled_by',
    ];


    protected function casts(): array
    {
        return [
            'needs_cooking' => 'boolean',
            'quantity'      => 'integer',
            'status'        => RequestStatus::class,
            'cancelled_by'  => CancelledBy::class,
            'valid_until'   => 'datetime',
            'pickup_until'  => 'datetime',
            'latitude'      => 'decimal:7',
            'longitude'     => 'decimal:7',
            'eta_minutes'   => 'integer',
            'accepted_at'          => 'datetime',
            'picked_up_at'         => 'datetime',
            'donor_confirmed_at'   => 'datetime',
            'charity_confirmed_at' => 'datetime',
            'completed_at'         => 'datetime',
        ];
    }

    /** True once both sides have pressed their own confirm button. */
    public function handoverFullyConfirmed(): bool
    {
        return $this->donor_confirmed_at !== null && $this->charity_confirmed_at !== null;
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

    public function images()
    {
        return $this->hasMany(DonationRequestImage::class)->orderBy('sort_order');
    }

    public function distribution()
    {
        return $this->hasOne(Distribution::class);
    }

    public function rating()
    {
        return $this->hasOne(Rating::class);
    }

    public function violations()
    {
        return $this->hasMany(Violation::class);
    }

    public function statusLogs()
    {
        return $this->hasMany(RequestStatusLog::class);
    }
}