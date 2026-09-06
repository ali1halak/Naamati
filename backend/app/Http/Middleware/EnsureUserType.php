<?php

namespace App\Http\Middleware;

use App\Enums\CharityStatus;
use App\Models\Charity;
use App\Models\Donor;
use Closure;
use Illuminate\Http\Request;

class EnsureUserType
{
    public function handle(Request $request, Closure $next, string $type)
    {
        $user = $request->user();
        $map  = ['donor' => Donor::class, 'charity' => Charity::class];
        $expected = $map[$type] ?? null;

        if (! $user || ! $expected || ! ($user instanceof $expected)) {
            return response()->json([
                'success' => false,
                'data'    => null,
                'message' => 'هذا الإجراء غير متاح لنوع حسابك',
            ], 403);
        }

        if ($type === 'charity' && $user->status !== CharityStatus::Active) {
            return response()->json([
                'success' => false,
                'data'    => null,
                'message' => 'حساب الجمعية غير مفعّل بعد',
            ], 403);
        }

        return $next($request);
    }
}