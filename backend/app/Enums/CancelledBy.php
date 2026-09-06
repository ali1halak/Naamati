<?php

namespace App\Enums;

enum CancelledBy: string
{
    case Donor = 'donor';
    case Admin = 'admin';

    /**
     * Short Arabic label for the history badge — the cancelled status alone is
     * ambiguous once two actors can trigger it.
     */
    public function label(): string
    {
        return match ($this) {
            self::Donor => 'ألغاه المتبرع',
            self::Admin => 'ألغته الإدارة',
        };
    }

    /**
     * Fuller wording for the audit screen.
     */
    public function detailedLabel(): string
    {
        return match ($this) {
            self::Donor => 'ألغاه المتبرع',
            self::Admin => 'ألغته الإدارة لكونه غير صالح',
        };
    }
}
