<?php

namespace App\Enums;

enum NotificationType: string
{
    /** A charity accepted a donation request. */
    case RequestAccepted = 'request_accepted';

    /** The donor confirmed the food changed hands. */
    case HandoverConfirmed = 'handover_confirmed';

    /** A request was cancelled — payload says by whom (donor or admin). */
    case RequestCancelled = 'request_cancelled';
}
