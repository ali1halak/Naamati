<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Models\Donor;
use App\Services\AuthService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    use ApiResponse;

    public function __construct(private AuthService $authService)
    {
    }

    public function register(RegisterRequest $request)
    {
        $result = $this->authService->register($request->validated());

        $token = $result['user']->createToken($result['type'] . '-auth')->plainTextToken;

        $message = $result['type'] === 'charity'
            ? 'Registered successfully. Your account is pending admin approval.'
            : 'Registered successfully';

        return $this->ok([
            'type'  => $result['type'],
            'user'  => $result['user'],
            'token' => $token,
        ], $message, 201);
    }

    public function login(LoginRequest $request)
    {
        $result = $this->authService->attemptLogin($request->email, $request->password);

        if (! $result) {
            return $this->fail('Invalid credentials', 401);
        }

        $token = $result['user']->createToken($result['type'] . '-auth')->plainTextToken;

        return $this->ok([
            'type'  => $result['type'],
            'user'  => $result['user'],
            'token' => $token,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return $this->ok(null, 'Logged out');
    }

    public function me(Request $request)
    {
        $user = $request->user();
        $type = $user instanceof Donor ? 'donor' : 'charity';

        return $this->ok([
            'type' => $type,
            'user' => $user,
        ]);
    }
}