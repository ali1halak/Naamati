<?php

namespace App\Services;

use App\Models\Charity;
use App\Models\Donor;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Exception\Messaging\NotFound;
use Kreait\Firebase\Exception\MessagingException;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification as FirebaseNotification;

/**
 * Sends a push notification to one account's registered device via FCM.
 *
 * Best-effort by design: a donor or charity without a registered token (or
 * one whose send fails) never blocks the request that triggered it — the
 * in-app notification row from NotificationService is always the source of
 * truth, this is just an extra nudge when the app isn't open.
 */
class PushNotificationService
{
    public function sendToUser(Donor|Charity $user, string $title, string $body, array $data = []): void
    {
        $token = $user->fcm_token;
        if (! $token) {
            return;
        }

        // FCM data payloads are string-only.
        $stringData = array_map(static fn ($value) => (string) $value, $data);

        $message = CloudMessage::new()
            ->withToken($token)
            ->withNotification(FirebaseNotification::create($title, $body))
            ->withData($stringData);

        try {
            // Resolved here, not via constructor injection: building this
            // eagerly would make Laravel load and validate the Firebase
            // service account for every controller that merely depends on
            // NotificationService (which every donation route does) — a
            // missing/misconfigured credential would then 500 on requests
            // that never send a single push. Deferring it to the moment of
            // sending puts a failure exactly where this catch can absorb it.
            app(Messaging::class)->send($message);
        } catch (NotFound) {
            // The token is no longer registered (app uninstalled / data
            // cleared) — drop it so we stop trying.
            $user->update(['fcm_token' => null]);
        } catch (MessagingException|\Throwable $e) {
            Log::warning('FCM send failed', [
                'user_type' => $user instanceof Donor ? 'donor' : 'charity',
                'user_id'   => $user->id,
                'error'     => $e->getMessage(),
            ]);
        }
    }
}
