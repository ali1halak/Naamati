<?php

namespace App\Enums;

enum RequestStatus: string
{
    case Pending   = 'pending';
    case Accepted  = 'accepted';
    case PickedUp  = 'picked_up';
    case Completed = 'completed';
    case Expired   = 'expired';
    case Cancelled = 'cancelled';
    case NoShow    = 'no_show';

    /**
     * Short Arabic label for the status badge on the history list.
     *
     * The API ships the text rather than a translation key: the app is
     * Arabic-only today, and one source of wording keeps the badge, the audit
     * screen and any future admin view from drifting apart. `status` is still
     * returned next to it, so a client that wants to localise itself can.
     */
    public function label(): string
    {
        return match ($this) {
            self::Pending   => 'بانتظار جمعية',
            self::Accepted  => 'تم قبوله',
            self::PickedUp  => 'مأخوذ',
            self::Completed => 'مكتمل',
            self::Expired   => 'منتهي الصلاحية',
            self::Cancelled => 'ملغى',
            self::NoShow    => 'لم تحضر الجمعية',
        };
    }

    /**
     * Fuller wording for the audit screen, which has room for a sentence.
     */
    public function detailedLabel(): string
    {
        return match ($this) {
            self::Pending   => 'منشور وبانتظار قبول جمعية',
            self::Accepted  => 'قبلته جمعية وهي في الطريق',
            self::PickedUp  => 'تم تسليم الطعام للجمعية',
            self::Completed => 'تم التوصيل والتوزيع بنجاح',
            self::Expired   => 'انتهت صلاحيته قبل أن تقبله جمعية',
            self::Cancelled => 'ألغاه المتبرع',
            self::NoShow    => 'قبلته جمعية ولم تحضر لاستلامه',
        };
    }

    /**
     * Which states this one may legally move to.
     *
     * This describes what is *physically* possible in the donation lifecycle.
     * Who is allowed to trigger a given move — and when — is a separate
     * question answered by DonationRequestPolicy.
     *
     * `picked_up` is reachable but unused for now: QR handover lands in a
     * later phase, so today the donor confirms accepted -> completed directly.
     */
    public function allowedTransitions(): array
    {
        return match ($this) {
            self::Pending  => [self::Accepted, self::Cancelled, self::Expired],
            self::Accepted => [self::PickedUp, self::Completed, self::Cancelled, self::NoShow],
            self::PickedUp => [self::Completed],

            self::Completed, self::Expired, self::Cancelled, self::NoShow => [],
        };
    }

    public function canTransitionTo(self $target): bool
    {
        return in_array($target, $this->allowedTransitions(), true);
    }

    /** No further move is possible — the request is closed for good. */
    public function isTerminal(): bool
    {
        return $this->allowedTransitions() === [];
    }

    /** Still moving: the donor sees it under "active" and cannot open a new one. */
    public function isActive(): bool
    {
        return ! $this->isTerminal();
    }

    /**
     * The statuses that stop a donor from opening a second request.
     *
     * Narrower than isActive() on purpose. "In flight" ends the moment the food
     * changes hands: from `picked_up` on, the request is only waiting for the
     * charity to file its distribution numbers, and that paperwork is no reason
     * to stop the donor from donating again.
     *
     * @return array<int, string>
     */
    public static function blockingNewRequestValues(): array
    {
        return [self::Pending->value, self::Accepted->value];
    }
}
