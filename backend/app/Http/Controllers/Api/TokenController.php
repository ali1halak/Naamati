<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\TokenService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class TokenController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly TokenService $tokens) {}

    /**
     * Exchange a refresh token for a fresh pair.
     *
     * Send the REFRESH token as the bearer here — the access token is refused,
     * because it lacks the `refresh` ability. The pair you send in dies with
     * this call, so store what comes back before making another request.
     */
    public function refresh(Request $request)
    {
        $pair = $this->tokens->rotate($request->user()->currentAccessToken());

        return $this->ok($pair, 'تم تجديد الجلسة');
    }
}
