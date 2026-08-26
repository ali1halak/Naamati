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
     * Register a donor or a charity.
     * Charities start as `pending` and stay unusable until an admin approves them.
     *
     * @return array{type: string, user: Model}
     */
    public function register(array $data): array
    {
        return $data['account_type'] === 'charity'
            ? ['type' => 'charity', 'user' => $this->createCharity($data)]
            : ['type' => 'donor', 'user' => $this->createDonor($data)];
    }

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

    private function createDonor(array $data): Donor
    {
        return Donor::create([
            'name'     => $data['name'],
            'type'     => $data['type'],
            'email'    => $data['email'],
            'phone'    => $data['phone'],
            'password' => $data['password'], // hashed by the model cast
        ]);
    }

    private function createCharity(array $data): Charity
    {
        // refresh() so time columns come back in their stored format (H:i:s),
        // matching what /me and every later endpoint return.
        return Charity::create([
            'name'             => $data['name'],
            'email'            => $data['email'],
            'phone'            => $data['phone'],
            'password'         => $data['password'], // hashed by the model cast
            'has_kitchen'      => $data['has_kitchen'],
            'address'          => $data['address'],
            'work_start'       => $data['work_start'],
            'work_end'         => $data['work_end'],
            'license_document' => $data['license_document'] ?? null,
            'status'           => CharityStatus::Pending, // admin must approve
        ])->refresh();
    }
}
