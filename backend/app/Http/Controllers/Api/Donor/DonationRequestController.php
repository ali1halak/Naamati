<?php

namespace App\Http\Controllers\Api\Donor;

use App\Enums\RequestStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Donor\CancelDonationRequest;
use App\Http\Requests\Donor\ConfirmPickupRequest;
use App\Http\Requests\Donor\StoreDonationRequest;
use App\Http\Requests\Donor\StoreRatingRequest;
use App\Http\Resources\DonationAuditResource;
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
            ->with(['foodCategory', 'charity', 'images'])
            ->latest();

        if ($status = $request->query('status')) {
            $allowed = array_column(RequestStatus::cases(), 'value');

            if (! in_array($status, $allowed, true)) {
                return $this->fail('فشل التحقق من البيانات', 422, [
                    'status' => ['الحالة المحددة غير صحيحة.'],
                ]);
            }

            $query->where('status', $status);
        }

        // Capped so one client cannot ask for the whole table in one page.
        $perPage = min(max((int) $request->query('per_page', 15), 1), 50);

        return $this->ok(DonationRequestResource::collection($query->paginate($perPage))->response()->getData(true));
    }

    /**
     * The audit view: what was given, how it travelled, and who it reached.
     */
    public function audit(Request $request, int $id)
    {
        $donationRequest = $this->ownedRequest($request, $id)
            ->load(['foodCategory', 'charity', 'distribution', 'rating', 'images']);

        return $this->ok(new DonationAuditResource($donationRequest));
    }

    public function store(StoreDonationRequest $request)
    {
        $donationRequest = $this->requests->create($request->user()->id, $request->validated());

        return $this->ok(
            new DonationRequestResource($donationRequest->load(['foodCategory', 'images'])),
            'تم نشر طلب التبرع',
            201
        );
    }

    public function show(Request $request, int $id)
    {
        $donationRequest = $this->ownedRequest($request, $id)
            ->load(['foodCategory', 'charity', 'distribution', 'rating', 'images']);

        return $this->ok(new DonationRequestResource($donationRequest));
    }

    public function cancel(CancelDonationRequest $request, int $id)
    {
        $donationRequest = $this->requests->cancel(
            $this->ownedRequest($request, $id),
            $request->validated()['reason'] ?? null
        );

        return $this->ok(
            new DonationRequestResource($donationRequest->load(['foodCategory', 'images'])),
            'تم إلغاء طلب التبرع'
        );
    }

    /**
     * The donor states the food changed hands. This notifies the admin that
     * this charity received from this donor.
     */
    public function confirm(Request $request, int $id)
    {
        $donationRequest = $this->requests->confirmHandoverByDonor(
            $this->ownedRequest($request, $id)
        );

        // Both buttons must be pressed before the food counts as handed over,
        // so say which of the two just happened.
        $message = $donationRequest->handoverFullyConfirmed()
            ? 'تم تأكيد تسليم الطعام'
            : 'تم تسجيل تأكيدك، بانتظار تأكيد الجمعية';

        return $this->ok(
            new DonationRequestResource($donationRequest->load(['foodCategory', 'charity'])),
            $message
        );
    }

    public function rate(StoreRatingRequest $request, int $id)
    {
        $donationRequest = $this->ownedRequest($request, $id);

        if ($donationRequest->rating()->exists()) {
            throw ValidationException::withMessages([
                'stars' => 'تم تقييم هذا التبرع مسبقاً.',
            ]);
        }

        $rating = $this->ratings->rate($donationRequest, $request->validated());

        return $this->ok(new RatingResource($rating), 'شكراً لتقييمك', 201);
    }
}
