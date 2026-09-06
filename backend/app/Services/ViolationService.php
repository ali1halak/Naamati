<?php

namespace App\Services;

use App\Enums\CharityStatus;
use App\Enums\ViolationSeverity;
use App\Enums\ViolationType;
use App\Models\Charity;
use App\Models\Violation;
use Illuminate\Support\Facades\DB;

class ViolationService
{
    /**
     * Weighted total at which an account is suspended automatically.
     *
     * Weighted, not counted: three late arrivals are worth flagging but they
     * are not three no-shows. See ViolationSeverity::weight().
     */
    public const SUSPENSION_THRESHOLD = 6;

    /**
     * File a compliance notice against a charity, and suspend the account if
     * the record has become bad enough.
     */
    public function record(Charity $charity, array $data): Violation
    {
        $type = ViolationType::from($data['reason']);

        $severity = isset($data['severity'])
            ? ViolationSeverity::from($data['severity'])
            : $type->defaultSeverity();

        return DB::transaction(function () use ($charity, $data, $type, $severity) {
            $violation = $charity->violations()->create([
                'donation_request_id' => $data['donation_request_id'] ?? null,
                'reason'              => $type,
                'severity'            => $severity,
                'admin_note'          => $data['admin_note'] ?? null,
            ]);

            if ($this->weightFor($charity) >= self::SUSPENSION_THRESHOLD
                && $charity->status === CharityStatus::Active) {
                $charity->update(['status' => CharityStatus::Suspended]);
            }

            return $violation;
        });
    }

    /**
     * How bad the charity's record currently is.
     *
     * Counts only what is on file now: approving a suspended charity clears its
     * violations, which is what gives an account a genuine fresh start.
     */
    public function weightFor(Charity $charity): int
    {
        return $charity->violations()
            ->get(['severity'])
            ->sum(fn (Violation $violation) => $violation->severity->weight());
    }
}
