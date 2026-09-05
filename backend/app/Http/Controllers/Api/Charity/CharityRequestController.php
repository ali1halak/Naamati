<?php

namespace App\Http\Controllers\Api\Charity;

use App\Http\Controllers\Controller;
use App\Http\Requests\Charity\AcceptDonationRequest;
use App\Http\Requests\Charity\StoreDistributionRequest;
use App\Http\Resources\CharityOrderResource;
use App\Http\Resources\DonationRequestResource;
use App\Models\DonationRequest;
use App\Services\DonationRequestService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class CharityRequestController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly DonationRequestService $requests,
    ) {}

    /**
     * Open requests this charity is eligible to take.
     */
    public function available(Request $request)
    {
        $paginated = $this->requests->availableFor($request->user())->paginate(15);

        return $this->ok(CharityOrderResource::collection($paginated)->response()->getData(true));
    }

    /**
     * Requests this charity has taken — its own work queue and history.
     */
    public function index(Request $request)
    {
        $paginated = DonationRequest::where('charity_id', $request->user()->id)
            ->with(['foodCategory', 'donor', 'distribution', 'images'])
            ->latest()
            ->paginate(15);

        return $this->ok(DonationRequestResource::collection($paginated)->response()->getData(true));
    }

    public function show(Request $request, int $id)
    {
        $donationRequest = DonationRequest::where('id', $id)
            ->where('charity_id', $request->user()->id)
            ->with(['foodCategory', 'donor', 'distribution', 'images'])
            ->firstOrFail();

        return $this->ok(new DonationRequestResource($donationRequest));
    }

    /**
     * Claim a request. Notifies the donor which charity is coming and when.
     */
    public function accept(AcceptDonationRequest $request, int $id)
    {
        $donationRequest = $this->requests->accept(
            DonationRequest::findOrFail($id),
            $request->user(),
            $request->validated()['eta_minutes']
        );

        return $this->ok(
            new DonationRequestResource($donationRequest->load('foodCategory', 'donor')),
            'تم قبول الطلب'
        );
    }

    /**
     * The charity's own half of the handover confirmation.
     */
    public function pickup(Request $request, int $id)
    {
        $donationRequest = $this->requests->confirmHandoverByCharity(
            DonationRequest::findOrFail($id),
            $request->user()
        );

        $message = $donationRequest->handoverFullyConfirmed()
            ? 'تم تأكيد استلام الطعام'
            : 'تم تسجيل تأكيدك، بانتظار تأكيد المتبرع';

        return $this->ok(
            new DonationRequestResource($donationRequest->load(['foodCategory', 'donor'])),
            $message
        );
    }

    /**
     * "تأكيد التوزيع" — the food has been handed out. Closes the request; the
     * beneficiary numbers can follow later.
     */
    public function complete(Request $request, int $id)
    {
        $donationRequest = $this->requests->completeDistribution(
            DonationRequest::findOrFail($id),
            $request->user()
        );

        return $this->ok(
            new DonationRequestResource($donationRequest->load(['foodCategory', 'donor'])),
            'تم تأكيد التوزيع'
        );
    }

    /**
     * "حفظ البيانات" — how many people the food reached.
     */
    public function impact(StoreDistributionRequest $request, int $id)
    {
        $donationRequest = $this->requests->recordImpact(
            DonationRequest::findOrFail($id),
            $request->user(),
            $request->validated()
        );

        return $this->ok(
            new DonationRequestResource(
                $donationRequest->load(['foodCategory', 'donor', 'distribution'])
            ),
            'تم حفظ بيانات التوزيع',
            201
        );
    }
}
