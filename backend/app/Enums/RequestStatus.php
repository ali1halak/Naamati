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
