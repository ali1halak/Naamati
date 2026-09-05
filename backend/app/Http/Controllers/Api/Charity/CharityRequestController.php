<?php

namespace App\Http\Controllers\Api\Charity;

use App\Http\Controllers\Controller;
use App\Http\Requests\Charity\AcceptDonationRequest;
use App\Http\Requests\Charity\StoreDistributionRequest;
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

        return $this->ok(DonationRequestResource::collection($paginated)->response()->getData(true));
    }

    /**
     * Requests this charity has taken — its own work queue and history.
     */
    public function index(Request $request)
    {
        $paginated = DonationRequest::where('charity_id', $request->user()->id)
            ->with(['foodCategory', 'donor', 'distribution'])
            ->latest()
            ->paginate(15);

        return $this->ok(DonationRequestResource::collection($paginated)->response()->getData(true));
    }

    public function show(Request $request, int $id)
    {
        $donationRequest = DonationRequest::where('id', $id)
            ->where('charity_id', $request->user()->id)
            ->with(['foodCategory', 'donor', 'distribution'])
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
     * File how many people the food actually reached. Closes the request.
     */
    public function distribute(StoreDistributionRequest $request, int $id)
    {
        $donationRequest = $this->requests->recordDistribution(
            DonationRequest::findOrFail($id),
            $request->user(),
            $request->validated()
        );

        return $this->ok(
            new DonationRequestResource(
                $donationRequest->load(['foodCategory', 'donor', 'distribution'])
            ),
            'تم تسجيل التوزيع',
            201
        );
    }
}
