<?php

namespace App\Http\Controllers\Api;

use App\Enums\NotificationType;
use App\Enums\RecipientType;
use App\Http\Controllers\Controller;
use App\Http\Resources\NotificationResource;
use App\Models\Donor;
use App\Models\Notification;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

/**
 * The signed-in donor's or charity's own notification feed.
 *
 * Admin notifications are served separately by Admin\AdminController, because
 * the admin authenticates with a static header rather than a Sanctum token.
 */
class NotificationController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $validated = $request->validate([
            'type' => ['nullable', Rule::in(array_column(NotificationType::cases(), 'value'))],
            // Not the `boolean` rule: it rejects the "true"/"false" strings a
            // mobile client naturally puts in a query string.
            'is_read' => ['nullable', Rule::in(['0', '1', 'true', 'false'])],
        ]);

        $query = $this->ownNotifications($request)
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

    public function markRead(Request $request, int $id)
    {
        $notification = $this->ownNotifications($request)->findOrFail($id);

        $notification->update(['is_read' => true]);

        return $this->ok(new NotificationResource($notification), 'Notification marked as read');
    }

    /**
     * Donors and charities live in separate tables, so their ids overlap: donor
     * 4 and charity 4 are different accounts. Both halves of the recipient key
     * have to match, or one account could read the other's feed.
     */
    private function ownNotifications(Request $request)
    {
        $user = $request->user();

        return Notification::query()
            ->where('recipient_type', $user instanceof Donor ? RecipientType::Donor : RecipientType::Charity)
            ->where('recipient_id', $user->id);
    }
}
