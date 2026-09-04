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
    private function guard(DonationRequest $r, array $allowedFrom, string $message = 'Invalid state transition'): void
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

        $this->log($request, null, RequestStatus::Pending);

        return $request;
    }

    /**
     * A charity claims the request. Locked so two charities racing on the same
     * request cannot both win it.
     */
    public function accept(DonationRequest $request, Charity $charity, int $etaMinutes): DonationRequest
    {
        return DB::transaction(function () use ($request, $charity, $etaMinutes) {
            $fresh = DonationRequest::whereKey($request->id)->lockForUpdate()->firstOrFail();

            $this->guard($fresh, [RequestStatus::Pending], 'Request is no longer available');

            if ($fresh->valid_until->isPast()) {
                throw ValidationException::withMessages(['status' => 'Request has expired']);
            }

            if ($fresh->needs_cooking && ! $charity->has_kitchen) {
                throw ValidationException::withMessages([
                    'status' => 'This food needs cooking and your charity has no kitchen',
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
     * The donor states the food changed hands. The admin is notified so there is
     * a record of which charity received from which donor.
     */
    public function confirmHandover(DonationRequest $request): DonationRequest
    {
        $this->guard($request, [RequestStatus::Accepted]);

        $from = $request->status;
        $request->update([
            'status'       => RequestStatus::PickedUp,
            'picked_up_at' => now(),
            'confirmed_at' => now(),
        ]);

        $this->log($request, $from, RequestStatus::PickedUp, 'confirmed by donor');
        $this->notifications->handoverConfirmed($request);

        return $request->refresh();
    }

    /**
     * The charity reports what it actually handed out, which closes the
     * request for good.
     *
     * This is the only way a request reaches `completed`: the donor confirming
     * the handover proves the food changed hands, but the donation is not
     * really done until somebody has eaten. Aggregate counts only — no
     * beneficiary is ever identified.
     */
    public function recordDistribution(DonationRequest $request, Charity $charity, array $data): DonationRequest
    {
        // 404-style guard would leak nothing, but the charity is legitimately
        // authenticated here — it just picked someone else's request.
        if ($request->charity_id !== $charity->id) {
            throw ValidationException::withMessages([
                'status' => 'This request was accepted by another charity',
            ]);
        }

        // Answered before the generic guard so a charity filing twice is told
        // what actually happened, instead of the misleading "not confirmed yet".
        if ($request->status === RequestStatus::Completed) {
            throw ValidationException::withMessages([
                'status' => 'Distribution has already been recorded for this request',
            ]);
        }

        $this->guard(
            $request,
            [RequestStatus::PickedUp],
            'The donor has not confirmed the handover yet'
        );

        return DB::transaction(function () use ($request, $data) {
            $request->distribution()->create([
                'families_count'    => $data['families_count'],
                'individuals_count' => $data['individuals_count'],
                'area'              => $data['area'],
                'notes'             => $data['notes'] ?? null,
                'distributed_at'    => $data['distributed_at'] ?? now(),
            ]);

            $from = $request->status;
            $request->update([
                'status'       => RequestStatus::Completed,
                'completed_at' => now(),
            ]);

            $this->log($request, $from, RequestStatus::Completed, 'distribution reported by charity');

            return $request->refresh();
        });
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
            ->with(['foodCategory', 'donor'])
            ->latest();
    }
}
