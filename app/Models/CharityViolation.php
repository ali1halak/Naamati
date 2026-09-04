<?php

namespace App\Models;

use Database\Factories\CharityViolationFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class CharityViolation extends Model
{
    /** @use HasFactory<CharityViolationFactory> */
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'charity_id',
        'order_id',
        'reason',
        'severity',
        'notes',
    ];

    public function charity(): BelongsTo
    {
        return $this->belongsTo(Charity::class);
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(DonationOrder::class, 'order_id');
    }
}
