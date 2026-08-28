<?php

namespace App\Services;

use App\Enums\CharityStatus;
use App\Models\Charity;
use App\Models\Donor;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Hash;

class AuthService
{
    /**
     * Attempt login across both the donor and charity tables.
     *
     * @return array{type: string, user: Model}|null
     */
    public function attemptLogin(string $email, string $password): ?array
    {
        $donor = Donor::where('email', $email)->first();
        if ($donor && Hash::check($password, $donor->password)) {
            return ['type' => 'donor', 'user' => $donor];
        }

        $charity = Charity::where('email', $email)->first();
        if ($charity && Hash::check($password, $charity->password)) {
            return ['type' => 'charity', 'user' => $charity];
        }

        return null;
    }

}
