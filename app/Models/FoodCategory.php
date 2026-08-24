<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FoodCategory extends Model
{
    protected $fillable = ['name_ar', 'name_en', 'default_needs_cooking'];

    protected function casts(): array
    {
        return [
            'default_needs_cooking' => 'boolean',
        ];
    }

    public function donationRequests()
    {
        return $this->hasMany(DonationRequest::class);
    }
}