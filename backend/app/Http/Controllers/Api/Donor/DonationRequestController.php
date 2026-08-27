<?php

namespace App\Http\Controllers\Api\Donor;

use App\Enums\RequestStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Donor\CancelDonationRequest;
use App\Http\Requests\Donor\ConfirmPickupRequest;
use App\Http\Requests\Donor\StoreDonationRequest;
use App\Http\Requests\Donor\StoreRatingRequest;
use App\Http\Resources\DonationRequestResource;
use App\Http\Resources\RatingResource;
use App\Models\DonationRequest;
use App\Services\DonationRequestService;
use App\Services\RatingService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class DonationRequestController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly DonationRequestService $requests,
        private readonly RatingService $ratings,
    ) {}

    /**
     * Load a request that belongs to the authenticated donor.
     * 404 rather than 403 so one donor cannot probe another's request ids.
     */
    private function ownedRequest(Request $httpRequest, int $id): DonationRequest
    {
        return DonationRequest::where('id', $id)
            ->where('donor_id', $httpRequest->user()->id)
            ->firstOrFail();
    }

    public function index(Request $request)
    {
        $query = DonationRequest::where('donor_id', $request->user()->id)
            ->with(['foodCategory', 'charity'])
            ->latest();

        if ($status = $request->query('status')) {
            $allowed = array_column(RequestStatus::cases(), 'value');

            if (! in_array($status, $allowed, true)) {
                return $this->fail('Validation failed', 422, [
                    'status' => ['The selected status is invalid.'],
                ]);
            }

            $query->where('status', $status);
        }

        return $this->ok(DonationRequestResource::collection($query->paginate(15))->response()->getData(true));
    }

    public function store(StoreDonationRequest $request)
    {
        $donationRequest = $this->requests->create($request->user()->id, $request->validated());

        return $this->ok(
            new DonationRequestResource($donationRequest->load('foodCategory')),
            'Donation request published',
            201
        );
    }

    public function show(Request $request, int $id)
    {
        $donationRequest = $this->ownedRequest($request, $id)
            ->load(['foodCategory', 'charity', 'distribution', 'rating']);

        return $this->ok(new DonationRequestResource($donationRequest));
    }

    public function cancel(CancelDonationRequest $request, int $id)
    {
        $donationRequest = $this->requests->cancel(
            $this->ownedRequest($request, $id),
            $request->validated()['reason'] ?? null
        );

        return $this->ok(
            new DonationRequestResource($donationRequest->load('foodCategory')),
            'Donation request cancelled'
        );
    }

    /**
     * The donor scans the QR the charity presents — this is what confirms the
     * food actually changed hands.
     */
    public function confirm(ConfirmPickupRequest $request, int $id)
    {
        $donationRequest = $this->requests->confirmPickup(
            $this->ownedRequest($request, $id),
            $request->validated()['qr_token']
        );

        return $this->ok(
            new DonationRequestResource($donationRequest->load(['foodCategory', 'charity'])),
            'Handover confirmed'
        );
    }

    public function rate(StoreRatingRequest $request, int $id)
    {
        $donationRequest = $this->ownedRequest($request, $id);

        if ($donationRequest->rating()->exists()) {
            throw ValidationException::withMessages([
                'stars' => 'This donation has already been rated.',
            ]);
        }

        $rating = $this->ratings->rate($donationRequest, $request->validated());

        return $this->ok(new RatingResource($rating), 'Thank you for your rating', 201);
    }
}
