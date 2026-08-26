<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ForceJsonResponse
{
    /**
     * Treat every API request as a JSON request, whatever the client sent.
     *
     * Without this, a request missing `Accept: application/json` makes Laravel
     * fall back to its browser behaviour: an expired token would try to
     * redirect to the `login` *route*, which does not exist in an API-only
     * app, and the client would get a 500 instead of a clean 401.
     */
    public function handle(Request $request, Closure $next)
    {
        $request->headers->set('Accept', 'application/json');

        return $next($request);
    }
}
