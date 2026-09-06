<?php

namespace App\Http\Controllers\Api\Donor;

use App\Enums\RequestStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Donor\CancelDonationRequest;
use App\Http\Requests\Donor\ConfirmPickupRequest;
use App\Http\Requests\Donor\StoreDonationRequest;
use App\Http\Requests\Donor\UpdateDonationRequest;
use App\Http\Requests\Donor\StoreRatingRequest;
use App\Http\Resources\DonationAuditResource;
use App\Http\Resources\DonationRequestResource;
use App\Http\Resources\RatingResource;
use App\Models\DonationRequest;
use App\Models\FoodCategory;
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

        $errors = $this->indexFilters($request, $search, $status, $category, $needsCooking, $from, $to);

        if ($errors !== null) {
            return $this->fail('فشل التحقق من البيانات', 422, $errors);
        }

        $query
            ->when($status !== null, fn ($q) => $q->where('status', $status))
            ->when($category !== null, fn ($q) => $q->where('food_category_id', $category))
            ->when($needsCooking !== null, fn ($q) => $q->where('needs_cooking', $needsCooking))
            ->when($from !== null, fn ($q) => $q->whereDate('created_at', '>=', $from))
            ->when($to !== null, fn ($q) => $q->whereDate('created_at', '<=', $to))
            ->when($search !== null, fn ($q) => $q->where(function ($q) use ($search) {
                // Note: `title` is a computed resource field (category name),
                // not a column — the category join below covers that text.
                // LIKE wildcards in the user input are escaped so "100%"
                // finds "100%" literally instead of matching everything.
                $term = str_replace(
                    ['\\', '%', '_'],
                    ['\\\\', '\\%', '\\_'],
                    $search,
                );

                $q->where('description', 'like', "%{$term}%")
                    ->orWhere('quantity_desc', 'like', "%{$term}%")
                    ->orWhere('custom_category', 'like', "%{$term}%")
                    ->orWhereHas(
                        'foodCategory',
                        fn ($c) => $c->where('name_ar', 'like', "%{$term}%"),
                    );
            }));

        // Capped so one client cannot ask for the whole table in one page.
        $perPage = min(max((int) $request->query('per_page', 15), 1), 50);

        return $this->ok(DonationRequestResource::collection($query->paginate($perPage))->response()->getData(true));
    }

    /**
     * Resolve and validate the history list filters.
     *
     * Fills the by-reference filter values and returns the validation error
     * array to fail the request with (or null when everything is valid).
     * Supported params: search (matches title/description/quantity/category
     * name), status, category (food_categories.id), needs_cooking (bool),
     * from/to (Y-m-d, inclusive, applied on created_at).
     */
    private function indexFilters(
        Request $request,
        ?string &$search,
        ?string &$status,
        ?int &$category,
        ?bool &$needsCooking,
        ?string &$from,
        ?string &$to,
    ): ?array {
        $errors = [];

        $search = trim((string) $request->query('search', ''));
        if ($search === '') {
            $search = null;
        }

        $status = $request->query('status');
        $allowed = array_column(RequestStatus::cases(), 'value');
        if ($status !== null && ! in_array($status, $allowed, true)) {
            $errors['status'] = ['The selected status is invalid.'];
            $status = null;
        }

        $category = null;
        if ($raw = $request->query('category')) {
            if (ctype_digit((string) $raw) && FoodCategory::whereKey($raw)->exists()) {
                $category = (int) $raw;
            } else {
                $errors['category'] = ['The selected category is invalid.'];
            }
        }

        $needsCooking = null;
        if (($raw = $request->query('needs_cooking')) !== null) {
            if (in_array($raw, ['1', 'true'], true)) {
                $needsCooking = true;
            } elseif (in_array($raw, ['0', 'false'], true)) {
                $needsCooking = false;
            } else {
                $errors['needs_cooking'] = ['The needs cooking filter must be true or false.'];
            }
        }

        $from = $this->indexDateFilter($request, 'from', $errors);
        $to = $this->indexDateFilter($request, 'to', $errors);

        return $errors === [] ? null : $errors;
    }

    /**
     * Read one Y-m-d date filter param, appending to [$errors] when malformed.
     */
    private function indexDateFilter(Request $request, string $key, array &$errors): ?string
    {
        $raw = $request->query($key);

        if ($raw === null) {
            return null;
        }

        $parts = explode('-', (string) $raw);
        if (count($parts) === 3 && checkdate((int) $parts[1], (int) $parts[2], (int) $parts[0])) {
            return $raw;
        }

        $errors[$key] = ["The $key date must be a valid Y-m-d date."];

        return null;
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

    public function update(UpdateDonationRequest $request, int $id)
    {
        // 404 rather than 403 so one donor cannot probe another's request ids.
        $existing = DonationRequest::where('id', $id)
            ->where('donor_id', $request->user()->id)
            ->firstOrFail();

        $donationRequest = $this->requests->update(
            $request->user()->id,
            $existing->id,
            $request->validated()
        );

        return $this->ok(
            new DonationRequestResource($donationRequest->load('foodCategory')),
            'Donation request updated'
        );
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
