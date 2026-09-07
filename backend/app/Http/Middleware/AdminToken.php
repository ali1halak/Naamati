<?php

namespace App\Http\Middleware;

use App\Models\Admin;
use Closure;
use Illuminate\Http\Request;
use Laravel\Sanctum\PersonalAccessToken;

/**
 * Guards the admin API.
 *
 * Two ways in, on purpose:
 *
 *  1. A Sanctum token belonging to an admin account — the real one. Every
 *     action is attributable to a person, and revoking one admin's access is
 *     deleting their tokens.
 *
 *  2. The static X-Admin-Token header — the original shortcut, kept only so
 *     existing Postman runs and scripts keep working. It is DEPRECATED: it
 *     names nobody, cannot be revoked for one person, and has to be embedded
 *     in whatever calls it. Move clients to POST /admin/login and drop this.
 *
 * When a bearer token is used, the resolved Admin is set on the request, so
 * controllers can rely on $request->user() the way every other route does.
 */
class AdminToken
{
    public function handle(Request $request, Closure $next)
    {
        if ($this->authenticateBearerAdmin($request) || $this->matchesStaticToken($request)) {
            return $next($request);
        }

        return response()->json([
            'success' => false,
            'data'    => null,
            'message' => 'رمز المشرف غير صحيح',
            'errors'  => null,
        ], 401);
    }

    /** Resolves a bearer token and accepts it only if it belongs to an admin. */
    private function authenticateBearerAdmin(Request $request): bool
    {
        $bearer = $request->bearerToken();

        if ($bearer === null) {
            return false;
        }

        $token = PersonalAccessToken::findToken($bearer);

        if ($token === null || ! $token->tokenable instanceof Admin) {
            return false;
        }

        if ($token->expires_at !== null && $token->expires_at->isPast()) {
            return false;
        }

        $token->forceFill(['last_used_at' => now()])->save();

        // withAccessToken is what makes $request->user()->currentAccessToken()
        // work; resolving the user alone leaves logout with nothing to revoke.
        $admin = $token->tokenable->withAccessToken($token);

        $request->setUserResolver(fn () => $admin);

        return true;
    }

    private function matchesStaticToken(Request $request): bool
    {
        $expected = (string) config('services.admin.token');
        $provided = (string) $request->header('X-Admin-Token');

        // A blank configured token must never pass, or an unset ADMIN_TOKEN
        // would open the whole admin API. hash_equals keeps it constant-time.
        return $expected !== '' && hash_equals($expected, $provided);
    }
}
