<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Profile\ChangePasswordRequest;
use App\Http\Requests\Profile\UpdateProfilePhotoRequest;
use App\Http\Requests\Profile\UpdateProfileRequest;
use App\Http\Resources\CharityProfileResource;
use App\Http\Resources\DonorProfileResource;
use App\Models\Charity;
use App\Models\Donor;
use App\Services\ProfileService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly ProfileService $profiles)
    {
    }

    /**
     * Wraps whichever resource matches the signed-in model in the same
     * `{type, profile}` shape `/me` and login/register already use, so the
     * client parses all of them the same way.
     */
    private function present(Request $request, Donor|Charity $user): array
    {
        $type = $user instanceof Donor ? 'donor' : 'charity';
        $profile = $user instanceof Donor
            ? new DonorProfileResource($user)
            : new CharityProfileResource($user);

        return ['type' => $type, 'profile' => $profile];
    }

    public function show(Request $request)
    {
        return $this->ok($this->present($request, $request->user()));
    }

    public function update(UpdateProfileRequest $request)
    {
        $user = $this->profiles->update($request->user(), $request->validated());

        return $this->ok($this->present($request, $user), 'تم تحديث الملف الشخصي');
    }

    public function updatePhoto(UpdateProfilePhotoRequest $request)
    {
        $user = $this->profiles->updatePhoto($request->user(), $request->file('photo'));

        return $this->ok($this->present($request, $user), 'تم تحديث الصورة');
    }

    public function changePassword(ChangePasswordRequest $request)
    {
        $this->profiles->changePassword($request->user(), $request->validated()['password']);

        return $this->ok(null, 'تم تغيير كلمة المرور');
    }
}
