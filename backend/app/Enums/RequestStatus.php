<?php

namespace App\Enums;

enum RequestStatus: string
{
    case Published = 'published';
    case Accepted  = 'accepted';
    case PickedUp  = 'picked_up';
    case Completed = 'completed';
    case Expired   = 'expired';
    case Cancelled = 'cancelled';
    case NoShow    = 'no_show';
}