<?php

namespace App\Services;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;
use Laravel\Sanctum\PersonalAccessToken;

/**
 * Issues and rotates the access/refresh token pair.
 *
 * WHY A PAIR
 * A single never-expiring token means a stolen phone stays signed in forever
 * and there is nothing the platform can do about it. Splitting the two puts a
 * short clock on the credential that travels with every request, while the
 * long-lived half sits in secure storage and is sent once an hour.
 *
 * ABILITIES ARE THE ENFORCEMENT
 * The access token carries `access`; the refresh token carries only `refresh`.
 * Ordinary routes require `access`, and POST /refresh requires `refresh` — so
 * a leaked refresh token cannot read data, and an expired access token cannot
 * mint itself a new one.
 *
 * ROTATION
 * Refreshing destroys the refresh token it was given. Presenting the same one
 * twice fails, which is what turns a copied token into a dead one the moment
 * the real client refreshes.
 *
 * SESSIONS
 * Both halves are named `{name}#{session}` so signing out on one device
 * revokes exactly that device's pair and leaves the others alone.
 */
class TokenService
{
    public const ACCESS_TTL_MINUTES = 60;

    public const REFRESH_TTL_DAYS = 30;

    /**
     * @return array{access_token: string, refresh_token: string, token_type: string, expires_in: int, token: string}
     */
    public function issue(Model $user, string $name): array
    {
        $session = Str::random(16);

        $access = $user->createToken(
            "{$name}#{$session}",
            ['access'],
            now()->addMinutes(self::ACCESS_TTL_MINUTES),
        );

        $refresh = $user->createToken(
            "{$name}-refresh#{$session}",
            ['refresh'],
            now()->addDays(self::REFRESH_TTL_DAYS),
        );

        return [
            'access_token'  => $access->plainTextToken,
            'refresh_token' => $refresh->plainTextToken,
            'token_type'    => 'Bearer',
            'expires_in'    => self::ACCESS_TTL_MINUTES * 60,

            // Kept so clients written against the old single-token response
            // keep working unchanged. It is the access token under another
            // name; new clients should read access_token.
            'token' => $access->plainTextToken,
        ];
    }

    /**
     * Exchange a refresh token for a fresh pair, destroying the one presented.
     */
    public function rotate(PersonalAccessToken $refreshToken): array
    {
        $user = $refreshToken->tokenable;
        $name = $this->baseName($refreshToken->name);

        // Drop the whole outgoing pair, not just the refresh half: leaving the
        // old access token alive would keep a stolen one usable for its
        // remaining hour after the real client had already moved on.
        $this->revokeSession($user, $refreshToken->name);

        return $this->issue($user, $name);
    }

    /** Signs one device out by removing both halves of its pair. */
    public function revokeSession(Model $user, string $tokenName): void
    {
        $session = $this->sessionOf($tokenName);

        if ($session === null) {
            // A token issued before sessions existed: revoke just that one.
            $user->tokens()->where('name', $tokenName)->delete();

            return;
        }

        $user->tokens()->where('name', 'like', '%#' . $session)->delete();
    }

    private function sessionOf(string $tokenName): ?string
    {
        $position = strrpos($tokenName, '#');

        return $position === false ? null : substr($tokenName, $position + 1);
    }

    /** "donor-auth-refresh#abc123" -> "donor-auth" */
    private function baseName(string $tokenName): string
    {
        $withoutSession = explode('#', $tokenName)[0];

        return str_ends_with($withoutSession, '-refresh')
            ? substr($withoutSession, 0, -strlen('-refresh'))
            : $withoutSession;
    }
}
