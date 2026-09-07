<?php

namespace App\Services;

use App\Enums\CancelledBy;
use App\Enums\NotificationType;
use App\Enums\RecipientType;
use App\Models\Charity;
use App\Models\DonationRequest;
use App\Models\Donor;
use App\Models\Notification;
use App\Models\Rating;
use Illuminate\Support\Collection;

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
     * A brand-new request was posted — every charity eligible to accept it
     * (same filter as `DonationRequestService::availableFor`, minus the
     * per-request violation exclusion, which cannot exist yet for a request
     * this new) gets nudged so they know to check the board.
     *
     * @param  Collection<int, Charity>  $charities
     */
    public function newRequestAvailable(DonationRequest $request, Collection $charities): void
    {
        $request->loadMissing('foodCategory');
        $categoryName = $request->foodCategory?->name;

        foreach ($charities as $charity) {
            $this->record(
                RecipientType::Charity,
                $charity->id,
                NotificationType::NewRequestAvailable,
                $request,
                ['category_name' => $categoryName],
                title: 'طلب تبرع جديد متاح',
                body: $categoryName
                    ? "تم نشر طلب تبرع جديد ({$categoryName}) قد يهمّك."
                    : 'تم نشر طلب تبرع جديد قد يهمّك.',
            );
        }
    }

    /**
     * One side confirmed the handover; the other has not yet — nudge them so
     * the request doesn't stall waiting on a button neither side knows is
     * still unpressed.
     *
     * @param  'donor'|'charity'  $confirmedBy
     */
    public function awaitingOtherConfirmation(DonationRequest $request, string $confirmedBy): void
    {
        $request->loadMissing(['donor', 'charity']);

        $waitingOn = $confirmedBy === 'donor' ? RecipientType::Charity : RecipientType::Donor;
        $waitingOnId = $confirmedBy === 'donor' ? $request->charity_id : $request->donor_id;

        if ($waitingOnId === null) {
            return;
        }

        $this->record(
            $waitingOn,
            $waitingOnId,
            NotificationType::AwaitingOtherConfirmation,
            $request,
            ['confirmed_by' => $confirmedBy],
            title: 'بانتظار تأكيدك',
            body: $confirmedBy === 'donor'
                ? 'أكّد المتبرع تسليم الطعام — أكّد استلامك من جهتك لإتمام العملية.'
                : 'أكّدت الجمعية استلام الطعام — أكّد تسليمك من جهتك لإتمام العملية.',
        );
    }

    /**
     * The charity filed the distribution as done — closes the loop for the
     * donor who has been waiting to know their food actually reached people.
     */
    public function distributionCompleted(DonationRequest $request): void
    {
        $request->loadMissing('charity');

        $this->record(
            RecipientType::Donor,
            $request->donor_id,
            NotificationType::DistributionCompleted,
            $request,
            ['charity_name' => $request->charity?->name],
            title: 'تم توزيع تبرعك',
            body: $request->charity?->name
                ? "وزّعت جمعية {$request->charity->name} تبرعك بنجاح. جزاك الله خيراً."
                : 'تم توزيع تبرعك بنجاح. جزاك الله خيراً.',
        );
    }

    /**
     * Nobody claimed the food before it expired.
     */
    public function requestExpired(DonationRequest $request): void
    {
        $this->record(
            RecipientType::Donor,
            $request->donor_id,
            NotificationType::RequestExpired,
            $request,
            [],
            title: 'انتهت صلاحية طلبك',
            body: 'انتهت صلاحية الطعام في طلبك دون أن تقبله أي جمعية.',
        );
    }

    /**
     * The charity that accepted a request never showed up by pickup_until.
     */
    public function requestNoShow(DonationRequest $request): void
    {
        $request->loadMissing('charity');

        $this->record(
            RecipientType::Donor,
            $request->donor_id,
            NotificationType::RequestNoShow,
            $request,
            ['charity_name' => $request->charity?->name],
            title: 'لم تحضر الجمعية',
            body: $request->charity?->name
                ? "لم تحضر جمعية {$request->charity->name} لاستلام طلبك في الموعد المحدد."
                : 'لم تحضر الجمعية المقبولة لاستلام طلبك في الموعد المحدد.',
        );
    }

    /**
     * The donor rated the charity — let the charity know it received feedback.
     */
    public function newRating(DonationRequest $request, Rating $rating): void
    {
        if ($request->charity_id === null) {
            return;
        }

        $this->record(
            RecipientType::Charity,
            $request->charity_id,
            NotificationType::NewRating,
            $request,
            ['stars' => $rating->stars, 'comment' => $rating->comment],
            title: 'تقييم جديد',
            body: "قيّمك أحد المتبرعين بـ {$rating->stars} من 5 نجوم.",
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
     * Admin approved (or reinstated) / suspended a charity account.
     */
    public function charityStatusChanged(Charity $charity, bool $approved): void
    {
        Notification::create([
            'recipient_type'      => RecipientType::Charity,
            'recipient_id'        => $charity->id,
            'type'                => $approved ? NotificationType::CharityApproved : NotificationType::CharitySuspended,
            'payload'             => [],
            'donation_request_id' => null,
        ]);

        $this->push->sendToUser(
            $charity,
            $approved ? 'تم تفعيل حسابك' : 'تم إيقاف حسابك',
            $approved
                ? 'تم اعتماد حساب جمعيتكم — يمكنكم الآن تصفح طلبات التبرع وقبولها.'
                : 'تم إيقاف حساب جمعيتكم من قبل الإدارة. للاستفسار يرجى التواصل معنا.',
        );
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
