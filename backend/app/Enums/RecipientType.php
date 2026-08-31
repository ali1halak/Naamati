<?php

namespace App\Enums;

enum RecipientType: string
{
    case Admin   = 'admin';
    case Donor   = 'donor';
    case Charity = 'charity';
}
