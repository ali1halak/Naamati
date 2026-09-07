<?php

namespace App\Models;

use App\Enums\DonorType;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\HasApiTokens;

class Donor extends Authenticatable
{
    use HasApiTokens;

    protected $fillable = ['name', 'type', 'email', 'phone', 'password', 'avatar_path'];
    protected $hidden   = ['password', 'remember_token', 'avatar_path'];

    protected $appends = ['avatar_url'];

    protected function casts(): array
    {
        return [
            'type'     => DonorType::class,
            'password' => 'hashed',
        ];
    }

    /** Absolute URL the app can load directly, or null while no avatar is set. */
    protected function avatarUrl(): Attribute
    {
        return Attribute::get(fn (): ?string => $this->avatar_path
            ? Storage::disk('public')->url($this->avatar_path)
            : null);
    }

    public function donationRequests()
    {
        return $this->hasMany(DonationRequest::class);
    }
}