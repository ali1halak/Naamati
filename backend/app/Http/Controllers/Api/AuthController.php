<?php

namespace App\Http\Controllers\Api;

use App\Enums\CharityStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\CharityRegisterRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Models\Charity;
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

    public function registerDonor(RegisterRequest $request)
    {
        $donor = Donor::create([
            'name'     => $request->name,
            'type'     => $request->type,
            'email'    => $request->email,
            'phone'    => $request->phone,
            'password' => $request->password,
        ]);

        $token = $donor->createToken('donor-auth')->plainTextToken;

        return $this->ok([
            'type'  => 'donor',
            'user'  => $donor,
            'token' => $token,
        ], 'تم إنشاء الحساب بنجاح', 201);
    }

    public function registerCharity(CharityRegisterRequest $request)
    {
        $licenseDocumentPath = null;

        if ($request->hasFile('license_document')) {
            $licenseDocumentPath = $request->file('license_document')->store(
                'license-documents',
                'public'
            );
        }

        $charity = Charity::create([
            'name'             => $request->name,
            'email'            => $request->email,
            'phone'            => $request->phone,
            'password'         => $request->password,
            'has_kitchen'      => $request->has_kitchen,
            'status'           => CharityStatus::Pending,
            'address'          => $request->address,
            'work_start'       => $request->work_start,
            'work_end'         => $request->work_end,
            'license_document'  => $licenseDocumentPath,
        ]);

        $token = $charity->createToken('charity-auth')->plainTextToken;

        return $this->ok([
            'type'  => 'charity',
            'user'  => $charity,
            'token' => $token,
        ], 'تم إنشاء الحساب بنجاح', 201);
    }

    public function login(LoginRequest $request)
    {
        $result = $this->authService->attemptLogin($request->email, $request->password);

        if (! $result) {
            return $this->fail('البريد الإلكتروني أو كلمة المرور غير صحيحة', 401);
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

        return $this->ok(null, 'تم تسجيل الخروج');
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