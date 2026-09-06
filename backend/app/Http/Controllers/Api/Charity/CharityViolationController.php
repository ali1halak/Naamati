<?php

namespace App\Http\Controllers\Api\Charity;

use App\Http\Controllers\Controller;
use App\Http\Resources\ViolationResource;
use App\Services\ViolationService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

/**
 * سجل المخالفات — the charity's own compliance record.
 *
 * Read-only by design: a charity can see everything filed against it and
 * change none of it. Only an admin writes here.
 */
class CharityViolationController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly ViolationService $violations) {}

    public function index(Request $request)
    {
        $charity = $request->user();

        $paginated = $charity->violations()->latest()->paginate(15);

        $payload = ViolationResource::collection($paginated)->response()->getData(true);

        // The charity should be able to see how close it is to a suspension,
        // not just be surprised by one.
        $payload['compliance'] = [
            'total_weight'         => $this->violations->weightFor($charity),
            'suspension_threshold' => ViolationService::SUSPENSION_THRESHOLD,
            'account_status'       => $charity->status->value,
        ];

        return $this->ok($payload);
    }
}
