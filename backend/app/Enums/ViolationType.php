<?php

namespace App\Enums;

enum ViolationType: string
{
    /** Accepted a request and never came for it. */
    case NoShow = 'no_show';

    /** Came, but well past the agreed pickup window. */
    case LatePickup = 'late_pickup';

    /** What was collected did not match what the donor listed. */
    case QuantityMismatch = 'quantity_mismatch';

    /** Reported impact numbers that do not add up. */
    case ImpactMismatch = 'impact_mismatch';

    /** Anything else an admin needs on the record. */
    case Other = 'other';

    /** The card title on the charity's compliance screen. */
    public function label(): string
    {
        return match ($this) {
            self::NoShow           => 'عدم الحضور لاستلام الطلب',
            self::LatePickup       => 'تأخر في استلام الطلب',
            self::QuantityMismatch => 'عدم مطابقة كمية التبرع',
            self::ImpactMismatch   => 'عدم مطابقة بيانات التوزيع',
            self::Other            => 'مخالفة أخرى',
        };
    }

    /**
     * Where a violation of this kind normally sits. An admin can override it
     * per case — a first late pickup is not the same as the fifth.
     */
    public function defaultSeverity(): ViolationSeverity
    {
        return match ($this) {
            self::NoShow           => ViolationSeverity::High,
            self::QuantityMismatch => ViolationSeverity::Medium,
            self::ImpactMismatch   => ViolationSeverity::Medium,
            self::LatePickup       => ViolationSeverity::Low,
            self::Other            => ViolationSeverity::Low,
        };
    }

    /** @return array<int, string> */
    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
