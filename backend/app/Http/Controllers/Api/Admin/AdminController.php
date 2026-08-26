<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Charity;
use App\Services\CharityService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class AdminController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly CharityService $charityService) {}

    public function charities(Request $request)
    {
        $validated = $request->validate([
            'status' => ['nullable', Rule::in(['pending', 'active', 'suspended'])],
        ]);

        return $this->ok($this->charityService->list($validated['status'] ?? null));
    }

    public function approve(Charity $charity)
    {
        return $this->ok(
            $this->charityService->approve($charity),
            'Charity approved'
        );
    }

    public function suspend(Charity $charity)
    {
        return $this->ok(
            $this->charityService->suspend($charity),
            'Charity suspended'
        );
    }
}
