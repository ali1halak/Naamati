<?php

namespace App\Services;

use App\Enums\CancelledBy;
use App\Enums\NotificationType;
use App\Enums\RecipientType;
use App\Models\Charity;
use App\Models\DonationRequest;
use App\Models\Donor;
use App\Models\Notification;

/**
 * Writes notification rows. Recipients read them through their own endpoints,
 * and — when they have a registered device — get an FCM push alongside it.
 *
 * The payload is denormalised on purpose: a notification should still read
 * correctly later even if the names it mentions change afterwards.
 */
class NotificationService
{
    public function __construct(private readonly PushNotificationService $push)
    {
    }

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
            title: 'تم قبول طلبك',
            body: $request->charity?->name
                ? "قبلت جمعية {$request->charity->name} طلب التبرع الخاص بك."
                : 'قبلت إحدى الجمعيات طلب التبرع الخاص بك.',
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
        $this->record(
            RecipientType::Charity,
            $request->charity_id,
            NotificationType::HandoverConfirmed,
            $request,
            $payload,
            title: 'تم تأكيد الاستلام',
            body: $request->donor?->name
                ? "تم تأكيد استلام التبرع من {$request->donor->name}."
                : 'تم تأكيد استلام التبرع.',
        );
    }

    /**
     * A request was cancelled. The other side always finds out: the donor is
     * told when the admin pulls their request, and the admin (plus an
     * attached charity, if any) is told when the donor pulls it back.
     */
    public function requestCancelled(DonationRequest $request, CancelledBy $by): void
    {
        $request->loadMissing(['donor', 'charity']);

        $payload = [
            'cancelled_by' => $by->value,
            'reason'       => $request->cancel_reason,
            'donor_name'   => $request->donor?->name,
        ];

        if ($by === CancelledBy::Admin) {
            $this->record(
                RecipientType::Donor,
                $request->donor_id,
                NotificationType::RequestCancelled,
                $request,
                $payload,
                title: 'تم إلغاء طلبك',
                body: 'قامت الإدارة بإلغاء طلب التبرع الخاص بك.',
            );

            return;
        }

        $this->record(RecipientType::Admin, null, NotificationType::RequestCancelled, $request, $payload);
        if ($request->charity_id !== null) {
            $this->record(
                RecipientType::Charity,
                $request->charity_id,
                NotificationType::RequestCancelled,
                $request,
                $payload,
                title: 'تم إلغاء الطلب',
                body: $request->donor?->name
                    ? "ألغى {$request->donor->name} طلب التبرع الذي قبلته."
                    : 'ألغى المتبرع طلب التبرع الذي قبلته.',
            );
        }
    }

    /**
     * Writes the in-app notification row and, for a donor/charity recipient
     * with $title/$body given, fires the matching push. Admin recipients
     * (a static header token, not a device) never get pushed to.
     */
    private function record(
        RecipientType $recipientType,
        ?int $recipientId,
        NotificationType $type,
        DonationRequest $request,
        array $payload,
        ?string $title = null,
        ?string $body = null,
    ): void {
        Notification::create([
            'recipient_type'      => $recipientType,
            'recipient_id'        => $recipientId,
            'type'                => $type,
            'payload'             => $payload,
            'donation_request_id' => $request->id,
        ]);

        if ($title === null || $body === null || $recipientId === null) {
            return;
        }

        $user = match ($recipientType) {
            RecipientType::Donor => Donor::find($recipientId),
            RecipientType::Charity => Charity::find($recipientId),
            RecipientType::Admin => null,
        };

        if ($user !== null) {
            $this->push->sendToUser($user, $title, $body, [
                'type'                => $type->value,
                'donation_request_id' => $request->id,
                'recipient_type'      => $recipientType->value,
            ]);
        }
    }
}
