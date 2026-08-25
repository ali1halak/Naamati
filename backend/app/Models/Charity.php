<?php

namespace App\Models;

use App\Enums\CharityStatus;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class Charity extends Authenticatable
{
    use HasApiTokens;

    protected $fillable = [
        'name', 'email', 'phone', 'password', 'has_kitchen',
        'status', 'license_document', 'address', 'work_start', 'work_end',
    ];
    protected $hidden = ['password', 'remember_token'];

    protected function casts(): array
    {
        return [
            'has_kitchen' => 'boolean',
            'status'      => CharityStatus::class,
            'password'    => 'hashed',
        ];
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