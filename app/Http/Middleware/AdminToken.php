<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AdminToken
{
    public function handle(Request $request, Closure $next)
    {
        if ($request->header('X-Admin-Token') !== config('services.admin.token')) {
            return response()->json([
                'success' => false,
                'data'    => null,
                'message' => 'Invalid admin token',
            ], 401);
        }

        return $next($request);
    }
}