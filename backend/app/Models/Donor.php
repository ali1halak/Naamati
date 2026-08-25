<?php

namespace App\Models;

use App\Enums\DonorType;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class Donor extends Authenticatable
{
    use HasApiTokens;

    protected $fillable = ['name', 'type', 'email', 'phone', 'password'];
    protected $hidden   = ['password', 'remember_token'];

    protected function casts(): array
    {
        return [
            'type'     => DonorType::class,
            'password' => 'hashed',
        ];
    }

    public function donationRequests()
    {
        return $this->hasMany(DonationRequest::class);
    }
}