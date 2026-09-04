<?php

namespace App\Models;

use Database\Factories\CharityFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Charity extends Model
{
    /** @use HasFactory<CharityFactory> */
    use HasFactory;

    protected $fillable = [
        'name',
        'logo_path',
        'region',
        'phone',
        'email',
        'active',
        'rating',
    ];

    protected $casts = [
        'active' => 'boolean',
        'rating' => 'decimal:1',
    ];

    public function orders(): HasMany
    {
        return $this->hasMany(DonationOrder::class);
    }

    public function violations(): HasMany
    {
        return $this->hasMany(CharityViolation::class);
    }
}
