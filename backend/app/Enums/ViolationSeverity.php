<?php

namespace App\Enums;

enum ViolationSeverity: string
{
    case Low    = 'low';
    case Medium = 'medium';
    case High   = 'high';

    public function label(): string
    {
        return match ($this) {
            self::Low    => 'منخفضة',
            self::Medium => 'متوسطة',
            self::High   => 'مرتفعة',
        };
    }

    /**
     * What one violation of this severity costs the charity.
     *
     * Suspension is weighted rather than a plain count: three late arrivals
     * are a pattern worth flagging, but they are not the same as three
     * charities-worth of food left to spoil.
     */
    public function weight(): int
    {
        return match ($this) {
            self::Low    => 1,
            self::Medium => 2,
            self::High   => 3,
        };
    }

    /** @return array<int, string> */
    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
