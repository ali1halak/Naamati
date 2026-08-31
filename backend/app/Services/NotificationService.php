<?php

namespace App\Services;

use App\Enums\NotificationType;
use App\Enums\RecipientType;
use App\Models\DonationRequest;
use App\Models\Notification;

/**
 * Writes notification rows. Recipients read them through their own endpoints;
 * nothing is pushed to a device yet.
 *
 * The payload is denormalised on purpose: a notification should still read
 * correctly later even if the names it mentions change afterwards.
 */
class NotificationService
{
    /**
     * A charity claimed a request — the donor needs to know who is coming.
     */
    public function requestAccepted(DonationRequest $request): void
    {
        $request->loadMissing(['donor', 'charity']);

        $this->record(
            RecipientType::Donor,
            $request->donor_id,
            NotificationType::RequestAccepted,
            $request,
            [
                'charity_name' => $request->charity?->name,
                'eta_minutes'  => $request->eta_minutes,
            ],
        );
    }

    /**
     * The handover happened. The admin gets the audit trail — "charity X
     * received from donor Y" — and the charity gets a confirmation.
     */
    public function handoverConfirmed(DonationRequest $request): void
    {
        $request->loadMissing(['donor', 'charity']);

        $payload = [
            'donor_id'     => $request->donor_id,
            'donor_name'   => $request->donor?->name,
            'charity_id'   => $request->charity_id,
            'charity_name' => $request->charity?->name,
        ];

        $this->record(RecipientType::Admin, null, NotificationType::HandoverConfirmed, $request, $payload);
        $this->record(RecipientType::Charity, $request->charity_id, NotificationType::HandoverConfirmed, $request, $payload);
    }

    private function record(
        RecipientType $recipientType,
        ?int $recipientId,
        NotificationType $type,
        DonationRequest $request,
        array $payload,
    ): void {
        Notification::create([
            'recipient_type'      => $recipientType,
            'recipient_id'        => $recipientId,
            'type'                => $type,
            'payload'             => $payload,
            'donation_request_id' => $request->id,
        ]);
    }
}
