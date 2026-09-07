<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Models\Admin;
use App\Services\TokenService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

/**
 * Admin sign-in for API clients.
 *
 * The Filament panel uses a session on the `admin` guard; anything else — a
 * separate dashboard front-end, a script — signs in here and gets a Sanctum
 * token instead. Both read the same admins table.
 *
 * There is no registration endpoint on purpose: accounts are created from the
 * server with `php artisan admin:create`.
 */
class AdminAuthController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly TokenService $tokens) {}

    public function login(LoginRequest $request)
    {
        $admin = Admin::where('email', $request->email)->first();

        // Same wording whichever half is wrong, so the response cannot be used
        // to work out which admin emails exist.
        if (! $admin || ! Hash::check($request->password, $admin->password)) {
            return $this->fail('البريد الإلكتروني أو كلمة المرور غير صحيحة', 401);
        }

        return $this->ok([
            'type' => 'admin',
            'user' => $admin,
            ...$this->tokens->issue($admin, 'admin-auth'),
        ], 'تم تسجيل الدخول');
    }

    public function me(Request $request)
    {
        return $this->ok([
            'type' => 'admin',
            'user' => $request->user(),
        ]);
    }

    /** Revokes only the token used for this call. */
    public function logout(Request $request)
    {
        $this->tokens->revokeSession($request->user(), $request->user()->currentAccessToken()->name);

        return $this->ok(null, 'تم تسجيل الخروج');
    }
}
