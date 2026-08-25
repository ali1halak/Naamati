<?php

namespace App\Enums;

enum CharityStatus: string
{
    case Pending   = 'pending';
    case Active    = 'active';
    case Suspended = 'suspended';
}