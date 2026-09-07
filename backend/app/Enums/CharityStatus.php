<?php

namespace App\Enums;

enum CharityStatus: string
{
    case Pending   = 'pending';
    case Active    = 'active';
    case Suspended = 'suspended';

    public function label(): string
    {
        return match ($this) {
            self::Pending   => 'قيد المراجعة',
            self::Active    => 'مفعّل',
            self::Suspended => 'موقوف',
        };
    }
}