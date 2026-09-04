<?php

namespace App\Models;

use Database\Factories\DonationOrderFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class DonationOrder extends Model
{
    /** @use HasFactory<DonationOrderFactory> */
    use HasFactory;

    protected $fillable = [
        'charity_id',
        'food_type',
        'quantity',
        'donor_name',
        'donor_phone',
        'donor_rating',
        'status',
        'delivered_at',
    ];

    protected $casts = [
        'donor_rating' => 'decimal:1',
        'delivered_at' => 'datetime',
    ];

    public function charity(): BelongsTo
    {
        return $this->belongsTo(Charity::class);
    }

    public function violations(): HasMany
    {
        return $this->hasMany(CharityViolation::class, 'order_id');
    }
}
