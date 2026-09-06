<?php

namespace App\Services;

use App\Enums\CancelledBy;
use App\Enums\RequestStatus;
use App\Enums\ViolationType;
use App\Models\Charity;
use App\Models\DonationRequest;
use App\Models\FoodCategory;
use App\Models\RequestStatusLog;
use App\Enums\ViolationSeverity;
use App\Models\Violation;
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

    /**
     * Normalise authored fields before they touch the model.
     *
     * `custom_category` is honoured ONLY under the "غير ذلك" category — a
     * donor sending it alongside a real category would otherwise spoof the
     * rendered title of the request.
     */
    private function sanitizeAuthored(array $data): array
    {
        $category = FoodCategory::findOrFail($data['food_category_id']);

        $custom = trim((string) ($data['custom_category'] ?? ''));
        $data['custom_category'] = $category->icon === 'other' && $custom !== ''
            ? $custom
            : null;

        // Same rule as the UI: only "غير ذلك" lets the donor pick the cooking
        // state — every real category forces its own default, so raw meat can
        // never be posted as "ready to eat" via a hand-crafted request.
        if ($category->icon !== 'other') {
            $data['needs_cooking'] = $category->default_needs_cooking;
        }

        if (array_key_exists('description', $data) && $data['description'] !== null) {
            $data['description'] = trim($data['description']) ?: null;
        }

        $data['pickup_address'] = trim((string) $data['pickup_address']);

        return $data;
    }

    public function create(int $donorId, array $data): DonationRequest
    {
        // Sanitise first so the cooking state below derives from the cleaned
        // data (the category default overrides any spoofed needs_cooking).
        $data = $this->sanitizeAuthored($data);

        // The donor may override it, but only under "غير ذلك" (sanitize keeps
        // the override); otherwise the category default wins.
        $needsCooking = $data['needs_cooking']
            ?? FoodCategory::findOrFail($data['food_category_id'])->default_needs_cooking;

        return DB::transaction(function () use ($donorId, $data, $needsCooking) {
            $request = DonationRequest::create([
                'donor_id'         => $donorId,
                'food_category_id' => $data['food_category_id'],
                'needs_cooking'    => $needsCooking,
                'quantity_desc'    => $data['quantity_desc'],
                'description'      => $data['description'] ?? null,
                'custom_category'  => $data['custom_category'] ?? null,
                'valid_until'      => $data['valid_until'],
                'pickup_until'     => $data['pickup_until'],
                'pickup_address'   => $data['pickup_address'],
                'pickup_notes'     => $data['pickup_notes'] ?? null,
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
     * The donor rewrites the details of a request nobody has claimed yet.
     *
     * Only `pending` is editable: once a charity accepted, people may already
     * be on the way, so the honest exits are confirm or cancel. The editable
     * set is exactly what the donor authored at create time — status, charity
     * and audit data are never touched here.
     */
    public function update(int $donorId, int $id, array $data): DonationRequest
    {
        $request = DonationRequest::where('id', $id)
            ->where('donor_id', $donorId)
            ->firstOrFail();

        if ($request->status !== RequestStatus::Pending) {
            throw ValidationException::withMessages([
                'status' => 'Only pending requests can be edited',
            ]);
        }

        $data = $this->sanitizeAuthored($data);

        $request->update([
            'food_category_id' => $data['food_category_id'],
            'needs_cooking'    => $data['needs_cooking']
                ?? FoodCategory::findOrFail($data['food_category_id'])->default_needs_cooking,
            'quantity_desc'    => $data['quantity_desc'],
            'description'      => $data['description'] ?? null,
            'custom_category'  => $data['custom_category'] ?? null,
            'valid_until'      => $data['valid_until'],
            'pickup_until'     => $data['pickup_until'],
            'pickup_address'   => $data['pickup_address'],
            'pickup_notes'     => $data['pickup_notes'] ?? null,
            'latitude'         => $data['latitude'] ?? null,
            'longitude'        => $data['longitude'] ?? null,
            'contact_phone'    => $data['contact_phone'],
        ]);

        return $request->refresh();
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
        return $this->doCancel($request, $reason, CancelledBy::Donor);
    }

    /**
     * Admin moderation cancel — for fake or invalid requests that would
     * otherwise stay stuck. Independent of the donor's own cancel path: any
     * pending/accepted request is cancellable regardless of its owner.
     */
    public function adminCancel(int $id, ?string $reason = null): DonationRequest
    {
        $request = DonationRequest::findOrFail($id);

        return $this->doCancel($request, $reason, CancelledBy::Admin);
    }

    private function doCancel(
        DonationRequest $request,
        ?string $reason,
        CancelledBy $by,
    ): DonationRequest {
        $this->guard($request, [RequestStatus::Pending, RequestStatus::Accepted]);

        $from = $request->status;
        $request->update([
            'status'        => RequestStatus::Cancelled,
            'cancel_reason' => $reason,
            'cancelled_by'  => $by,
        ]);

        $this->log($request, $from, RequestStatus::Cancelled, $reason ?? "cancelled by {$by->value}");
        $this->notifications->requestCancelled($request, $by);

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
                // A charity with a violation on a request never sees it again.
                $sub->select('donation_request_id')
                    ->from('violations')
                    ->where('charity_id', $charity->id)
                    ->whereNotNull('donation_request_id');
            })
            ->with(['foodCategory', 'images'])
            ->latest();
    }

    /**
     * Time-driven transitions no player triggers:
     *
     *  - `pending` past `valid_until`  -> `expired`
     *    (nobody wanted the food while it was still edible)
     *  - `accepted` past `pickup_until` -> `no_show`
     *    (a charity committed and never came — it takes a strike)
     *
     * Invoked by the scheduled `donations:expire-stale` command. Each row is
     * re-checked under a lock inside its own transaction, so the command is
     * safe to run repeatedly or concurrently and can never double-strike.
     *
     * @return array{expired: int, no_show: int}
     */
    public function expireStale(): array
    {
        return [
            'expired' => $this->expirePendingPastValidity(),
            'no_show' => $this->expireAcceptedPastPickup(),
        ];
    }

    private function expirePendingPastValidity(): int
    {
        $ids = DonationRequest::query()
            ->where('status', RequestStatus::Pending)
            ->where('valid_until', '<', now())
            ->pluck('id');

        $count = 0;
        foreach ($ids as $id) {
            $changed = DB::transaction(function () use ($id) {
                $r = DonationRequest::whereKey($id)->lockForUpdate()->first();

                if ($r === null || $r->status !== RequestStatus::Pending) {
                    return false; // already moved on (accepted/cancelled/…)
                }
                if ($r->valid_until->isFuture()) {
                    return false; // raced against the clock — leave it
                }

                $from = $r->status;
                $r->update(['status' => RequestStatus::Expired]);
                $this->log($r, $from, RequestStatus::Expired, 'انتهت صلاحية الطعام قبل أن تقبله جمعية');

                return true;
            });
            $count += $changed ? 1 : 0;
        }

        return $count;
    }

    private function expireAcceptedPastPickup(): int
    {
        $ids = DonationRequest::query()
            ->where('status', RequestStatus::Accepted)
            ->where('pickup_until', '<', now())
            ->pluck('id');

        $count = 0;
        foreach ($ids as $id) {
            $changed = DB::transaction(function () use ($id) {
                $r = DonationRequest::whereKey($id)->lockForUpdate()->first();

                if ($r === null || $r->status !== RequestStatus::Accepted) {
                    return false; // confirmed or cancelled meanwhile
                }
                if ($r->pickup_until->isFuture()) {
                    return false;
                }

                $from = $r->status;
                $r->update(['status' => RequestStatus::NoShow]);
                $this->log($r, $from, RequestStatus::NoShow, 'لم تحضر الجمعية في الموعد المحدد');

                if ($r->charity_id !== null) {
                    Violation::create([
                        'charity_id'          => $r->charity_id,
                        'donation_request_id' => $r->id,
                        'reason'              => ViolationType::NoShow,
                        'severity'            => ViolationSeverity::Medium,
                        'admin_note'          => 'أوتوماتيكياً: تخطّت آخر وقت للاستلام دون تأكيد تسليم',
                    ]);
                }

                return true;
            });
            $count += $changed ? 1 : 0;
        }

        return $count;
    }
}
