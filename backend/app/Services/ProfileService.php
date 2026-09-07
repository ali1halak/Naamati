<?php

namespace App\Services;

use App\Models\Charity;
use App\Models\Donor;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

/**
 * Self-service account management for the signed-in donor or charity.
 *
 * Donor and Charity are independent Sanctum-auth models (no shared base), so
 * every method here branches on which one it was handed rather than relying
 * on a common parent.
 */
class ProfileService
{
    public function update(Donor|Charity $user, array $data): Donor|Charity
    {
        $user->update($data);

        return $user->refresh();
    }

    /**
     * Replaces the profile photo (donor avatar / charity logo), deleting the
     * previous file first — mirrors DonationRequestService::syncImages's
     * delete-then-store idiom.
     */
    public function updatePhoto(Donor|Charity $user, UploadedFile $file): Donor|Charity
    {
        $column = $user instanceof Donor ? 'avatar_path' : 'logo_path';
        $folder = $user instanceof Donor ? 'donor-avatars' : 'charity-logos';

        $existing = $user->{$column};
        if ($existing) {
            Storage::disk('public')->delete($existing);
        }

        $user->update([$column => $file->store($folder, 'public')]);

        return $user->refresh();
    }

    /**
     * The `password => hashed` cast on both models hashes this on save.
     */
    public function changePassword(Donor|Charity $user, string $newPassword): void
    {
        $user->update(['password' => $newPassword]);
    }

    /**
     * Registers this device as the account's push target. One token per
     * account (last login/refresh wins) — see AuthController::logout for
     * where it gets cleared again.
     */
    public function updateFcmToken(Donor|Charity $user, string $token): void
    {
        $user->update(['fcm_token' => $token]);
    }
}
