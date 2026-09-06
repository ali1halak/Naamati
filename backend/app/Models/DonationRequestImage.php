<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class DonationRequestImage extends Model
{
    protected $fillable = ['donation_request_id', 'path', 'sort_order'];

    // The stored path is an implementation detail; clients only ever get a URL.
    protected $hidden = ['path'];

    protected $appends = ['url'];

    protected function url(): Attribute
    {
        return Attribute::get(fn (): string => Storage::disk('public')->url($this->path));
    }

    public function donationRequest()
    {
        return $this->belongsTo(DonationRequest::class);
    }
}
