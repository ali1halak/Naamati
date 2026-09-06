<?php

namespace App\Models;

use App\Enums\ViolationSeverity;
use App\Enums\ViolationType;
use Illuminate\Database\Eloquent\Model;

/**
 * A compliance notice filed against a charity by an admin.
 *
 * Violations are what the charity reads on its سجل المخالفات screen, and what
 * the platform counts when deciding whether an account should be suspended.
 */
class Violation extends Model
{
    protected $fillable = ['charity_id', 'donation_request_id', 'reason', 'severity', 'admin_note'];

    protected function casts(): array
    {
        return [
            'reason'   => ViolationType::class,
            'severity' => ViolationSeverity::class,
        ];
    }

    public function charity()
    {
        return $this->belongsTo(Charity::class);
    }

    public function donationRequest()
    {
        return $this->belongsTo(DonationRequest::class);
    }
}
