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

    /** A new request was posted — sent to every eligible charity. */
    case NewRequestAvailable = 'new_request_available';

    /** One side confirmed the handover; the other still needs to. */
    case AwaitingOtherConfirmation = 'awaiting_other_confirmation';

    /** The charity filed the distribution as done. */
    case DistributionCompleted = 'distribution_completed';

    /** A pending request's food expired before any charity claimed it. */
    case RequestExpired = 'request_expired';

    /** An accepted request's charity never showed up by pickup_until. */
    case RequestNoShow = 'request_no_show';

    /** The donor left a rating on the charity that received the food. */
    case NewRating = 'new_rating';

    /** Admin approved (or reinstated) a charity account. */
    case CharityApproved = 'charity_approved';

    /** Admin suspended a charity account. */
    case CharitySuspended = 'charity_suspended';
}
