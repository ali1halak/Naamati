<?php

namespace App\Http\Controllers\Api\Admin;

use App\Enums\NotificationType;
use App\Enums\RecipientType;
use App\Http\Controllers\Controller;
use App\Http\Resources\NotificationResource;
use App\Models\Charity;
use App\Models\Notification;
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

    /**
     * The admin's activity feed — currently every confirmed handover, i.e.
     * which charity received from which donor.
     */
    public function notifications(Request $request)
    {
        $validated = $request->validate([
            'type' => ['nullable', Rule::in(array_column(NotificationType::cases(), 'value'))],
            // Not the `boolean` rule: it rejects the "true"/"false" strings a
            // mobile client naturally puts in a query string.
            'is_read' => ['nullable', Rule::in(['0', '1', 'true', 'false'])],
        ]);

        $query = Notification::where('recipient_type', RecipientType::Admin)
            ->when($validated['type'] ?? null, fn ($q, $type) => $q->where('type', $type))
            ->when(
                isset($validated['is_read']),
                fn ($q) => $q->where('is_read', $request->boolean('is_read'))
            )
            ->latest();

        return $this->ok(
            NotificationResource::collection($query->paginate(15))->response()->getData(true)
        );
    }

    public function markNotificationRead(int $id)
    {
        $notification = Notification::where('recipient_type', RecipientType::Admin)
            ->findOrFail($id);

        $notification->update(['is_read' => true]);

        return $this->ok(new NotificationResource($notification), 'Notification marked as read');
    }
}
