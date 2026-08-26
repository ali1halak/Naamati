<?php

namespace App\Models;

use App\Enums\CharityStatus;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\HasApiTokens;

class Charity extends Authenticatable
{
    use HasApiTokens;

    protected $fillable = [
        'name', 'email', 'phone', 'password', 'has_kitchen',
        'status', 'license_document', 'logo_path', 'address', 'work_start', 'work_end',
    ];

    // rating_avg / ratings_count are derived columns owned by RatingObserver —
    // deliberately not fillable so nothing can write them by hand.
    protected $hidden = ['password', 'remember_token', 'logo_path'];

    protected $appends = ['logo_url'];

    protected function casts(): array
    {
        return [
            'has_kitchen'   => 'boolean',
            'status'        => CharityStatus::class,
            'password'      => 'hashed',
            'rating_avg'    => 'float',
            'ratings_count' => 'integer',
        ];
    }

    /** Absolute URL the app can load directly, or null while no logo is set. */
    protected function logoUrl(): Attribute
    {
        return Attribute::get(fn (): ?string => $this->logo_path
            ? Storage::disk('public')->url($this->logo_path)
            : null);
    }

    public function donationRequests()
    {
        return $this->hasMany(DonationRequest::class);
    }

    public function strikes()
    {
        return $this->hasMany(Strike::class);
    }
}