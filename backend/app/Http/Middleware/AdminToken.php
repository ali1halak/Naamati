<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AdminToken
{
    public function handle(Request $request, Closure $next)
    {
        $expected = (string) config('services.admin.token');
        $provided = (string) $request->header('X-Admin-Token');

        // Refuse outright if no token is configured, otherwise a missing
        // ADMIN_TOKEN would let every request through. hash_equals keeps the
        // comparison constant-time.
        if ($expected === '' || ! hash_equals($expected, $provided)) {
            return response()->json([
                'success' => false,
                'data'    => null,
                'message' => 'رمز المشرف غير صحيح',
                'errors'  => null,
            ], 401);
        }

        return $next($request);
    }
}
