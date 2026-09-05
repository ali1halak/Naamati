<?php

namespace App\Services;

use App\Enums\RequestStatus;
use App\Models\Charity;
use App\Models\DonationRequest;
use App\Models\FoodCategory;
use App\Models\RequestStatusLog;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

/**
 * Every donation-request state change goes through this service.
 *
 * Keeping transitions in one place means a request can never reach an
 * impossible state from some stray controller, and every move is written to
 * request_status_logs for auditing.
 */
class DonationRequestService
{
    public function __construct(
        private readonly NotificationService $notifications,
    ) {}

    private function log(DonationRequest $r, ?RequestStatus $from, RequestStatus $to, ?string $note = null): void
    {
        RequestStatusLog::create([
            'donation_request_id' => $r->id,
            'from_status'         => $from?->value,
            'to_status'           => $to->value,
            'note'                => $note,
        ]);
    }

    /**
     * Refuse the move instead of silently corrupting the record.
     */
    private function guard(DonationRequest $r, array $allowedFrom, string $message = 'لا يمكن تنفيذ هذا الإجراء على الطلب في حالته الحالية'): void
    {
        if (! in_array($r->status, $allowedFrom, true)) {
            throw ValidationException::withMessages(['status' => $message]);
        }
    }

    public function create(int $donorId, array $data): DonationRequest
    {
        // The donor may override it, but by default the category decides whether
        // the food needs cooking — that flag drives the no-kitchen filter.
        $needsCooking = $data['needs_cooking']
            ?? FoodCategory::findOrFail($data['food_category_id'])->default_needs_cooking;

        return DB::transaction(function () use ($donorId, $data, $needsCooking) {
            $request = DonationRequest::create([
                'donor_id'         => $donorId,
                'food_category_id' => $data['food_category_id'],
                'needs_cooking'    => $needsCooking,
                'quantity_desc'    => $data['quantity_desc'],
                'description'      => $data['description'] ?? null,
                'valid_until'      => $data['valid_until'],
                'pickup_until'     => $data['pickup_until'],
                'pickup_address'   => $data['pickup_address'],
                'latitude'         => $data['latitude'] ?? null,
                'longitude'        => $data['longitude'] ?? null,
                'contact_phone'    => $data['contact_phone'],
                'status'           => RequestStatus::Pending,
            ]);

            // Stored inside the transaction so a failure halfway through does
            // not leave a request whose photos are missing.
            foreach (array_values($data['images'] ?? []) as $position => $file) {
                $request->images()->create([
                    'path'       => $file->store('donation-images', 'public'),
                    'sort_order' => $position,
                ]);
            }

            $this->log($request, null, RequestStatus::Pending);

            return $request;
        });
    }

    /**
     * A charity claims the request. Locked so two charities racing on the same
     * request cannot both win it.
     */
    public function accept(DonationRequest $request, Charity $charity, int $etaMinutes): DonationRequest
    {
        return DB::transaction(function () use ($request, $charity, $etaMinutes) {
            $fresh = DonationRequest::whereKey($request->id)->lockForUpdate()->firstOrFail();

            $this->guard($fresh, [RequestStatus::Pending], 'لم يعد هذا الطلب متاحاً');

            if ($fresh->valid_until->isPast()) {
                throw ValidationException::withMessages(['status' => 'انتهت صلاحية هذا الطلب']);
            }

            if ($fresh->needs_cooking && ! $charity->has_kitchen) {
                throw ValidationException::withMessages([
                    'status' => 'هذا الطعام يحتاج طهياً وجمعيتكم لا تملك مطبخاً.',
                ]);
            }

            $from = $fresh->status;
            $fresh->update([
                'charity_id'  => $charity->id,
                'status'      => RequestStatus::Accepted,
                'accepted_at' => now(),
                'eta_minutes' => $etaMinutes,
            ]);

            $this->log($fresh, $from, RequestStatus::Accepted, "accepted by charity #{$charity->id}");
            $this->notifications->requestAccepted($fresh);

            return $fresh->refresh();
        });
    }

    /**
     * One side states the food changed hands.
     *
     * The request only reaches `picked_up` once BOTH sides have pressed their
     * own button. A single party cannot record a handover the other never
     * agreed to, which is the whole point: neither can claim the food moved
     * when it did not.
     *
     * The donor's half. Ownership is already established by the caller, which
     * loads the request scoped to the signed-in donor.
     */
    public function confirmHandoverByDonor(DonationRequest $request): DonationRequest
    {
        return $this->confirmHandoverBy($request, 'donor');
    }

    /**
     * The charity's half. Unlike the donor route there is no owner-scoped
     * lookup here, so the claim has to be checked: without this any active
     * charity could confirm a handover on a request it never accepted.
     */
    public function confirmHandoverByCharity(DonationRequest $request, Charity $charity): DonationRequest
    {
        $this->assertAcceptedBy($request, $charity);

        return $this->confirmHandoverBy($request, 'charity');
    }

    /**
     * @param 'donor'|'charity' $party
     */
    private function confirmHandoverBy(DonationRequest $request, string $party): DonationRequest
    {
        $this->guard($request, [RequestStatus::Accepted]);

        $column = $party === 'donor' ? 'donor_confirmed_at' : 'charity_confirmed_at';

        if ($request->{$column} !== null) {
            throw ValidationException::withMessages([
                'status' => 'سبق أن أكّدت تسليم هذا الطلب.',
            ]);
        }

        return DB::transaction(function () use ($request, $column, $party) {
            $request->update([$column => now()]);
            $request->refresh();

            // Still waiting on the other side — the status deliberately stays
            // `accepted` so the app can show "بانتظار تأكيد الطرف الآخر".
            if (! $request->handoverFullyConfirmed()) {
                return $request;
            }

            $from = $request->status;
            $request->update([
                'status'       => RequestStatus::PickedUp,
                'picked_up_at' => now(),
            ]);

            $this->log($request, $from, RequestStatus::PickedUp, "confirmed by both sides, last: {$party}");
            $this->notifications->handoverConfirmed($request);

            return $request->refresh();
        });
    }

    /**
     * The charity states the food has been handed out, which closes the
     * request.
     *
     * Deliberately separate from the beneficiary numbers: a charity finishing
     * a distribution at night should not have to count families before it can
     * mark the job done, and a request left waiting on paperwork would never
     * reach `completed`.
     */
    public function completeDistribution(DonationRequest $request, Charity $charity): DonationRequest
    {
        $this->assertAcceptedBy($request, $charity);

        if ($request->status === RequestStatus::Completed) {
            throw ValidationException::withMessages([
                'status' => 'سبق تأكيد توزيع هذا الطلب.',
            ]);
        }

        $this->guard(
            $request,
            [RequestStatus::PickedUp],
            'لم يكتمل تأكيد الاستلام من الطرفين بعد'
        );

        $from = $request->status;
        $request->update([
            'status'       => RequestStatus::Completed,
            'completed_at' => now(),
        ]);

        $this->log($request, $from, RequestStatus::Completed, 'distribution confirmed by charity');

        return $request->refresh();
    }

    /**
     * How many people the food actually reached. Filed right after the
     * distribution or any time later — "تعبئة لاحقاً" on the impact screen.
     * Aggregate counts only; no beneficiary is ever identified.
     */
    public function recordImpact(DonationRequest $request, Charity $charity, array $data): DonationRequest
    {
        $this->assertAcceptedBy($request, $charity);

        if ($request->status !== RequestStatus::Completed) {
            throw ValidationException::withMessages([
                'status' => 'أكّد التوزيع أولاً قبل إدخال أرقام المستفيدين.',
            ]);
        }

        if ($request->distribution()->exists()) {
            throw ValidationException::withMessages([
                'status' => 'تم تسجيل أرقام التوزيع لهذا الطلب مسبقاً.',
            ]);
        }

        $request->distribution()->create([
            'families_count'    => $data['families_count'],
            'individuals_count' => $data['individuals_count'],
            'area'              => $data['area'],
            'notes'             => $data['notes'] ?? null,
            'distributed_at'    => $data['distributed_at'] ?? now(),
        ]);

        return $request->refresh();
    }

    /**
     * A 404 would leak nothing, but the charity here is legitimately signed in
     * and simply acting on a request it never claimed — say so plainly.
     */
    private function assertAcceptedBy(DonationRequest $request, Charity $charity): void
    {
        if ($request->charity_id !== $charity->id) {
            throw ValidationException::withMessages([
                'status' => 'هذا الطلب قبلته جمعية أخرى.',
            ]);
        }
    }

    public function cancel(DonationRequest $request, ?string $reason = null): DonationRequest
    {
        $this->guard($request, [RequestStatus::Pending, RequestStatus::Accepted]);

        $from = $request->status;
        $request->update([
            'status'        => RequestStatus::Cancelled,
            'cancel_reason' => $reason,
        ]);

        $this->log($request, $from, RequestStatus::Cancelled, $reason);

        return $request->refresh();
    }

    /**
     * Only requests this charity is allowed to see: still open, still edible,
     * and — if the food needs cooking — only charities that own a kitchen.
     */
    public function availableFor(Charity $charity): Builder
    {
        return DonationRequest::query()
            ->where('status', RequestStatus::Pending)
            ->where('valid_until', '>', now())
            ->when(! $charity->has_kitchen, fn ($q) => $q->where('needs_cooking', false))
            ->whereNotIn('id', function ($sub) use ($charity) {
                // A charity that no-showed never sees that same request again.
                $sub->select('donation_request_id')
                    ->from('strikes')
                    ->where('charity_id', $charity->id)
                    ->whereNotNull('donation_request_id');
            })
            ->with(['foodCategory', 'images'])
            ->latest();
    }
}
