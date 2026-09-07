<?php

namespace Tests\Feature;

use App\Models\Admin;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Tests\TestCase;

/**
 * Admin sign-in over the API, and what the admin routes will and will not
 * accept as proof of being an admin.
 */
class AdminApiAuthTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Cache::clear();
        config(['services.admin.token' => 'test-admin-token']);

        Admin::create([
            'name' => 'مدير النظام', 'email' => 'admin@test.com', 'password' => 'password123',
        ]);
    }

    private function login(): string
    {
        return $this->postJson('/api/v1/admin/login', [
            'email' => 'admin@test.com', 'password' => 'password123',
        ])->assertOk()->json('data.token');
    }

    private function asAdmin(string $token): self
    {
        $this->app['auth']->forgetGuards();
        $this->flushHeaders();

        return $this->withHeader('Authorization', 'Bearer ' . $token);
    }

    public function test_an_admin_can_sign_in_and_gets_a_token(): void
    {
        $this->postJson('/api/v1/admin/login', [
            'email' => 'admin@test.com', 'password' => 'password123',
        ])
            ->assertOk()
            ->assertJsonPath('data.type', 'admin')
            ->assertJsonPath('data.user.email', 'admin@test.com')
            ->assertJsonStructure(['data' => ['token']])
            // The hash must never travel with the account.
            ->assertJsonMissingPath('data.user.password');
    }

    public function test_wrong_credentials_are_refused_without_saying_which_half(): void
    {
        $this->postJson('/api/v1/admin/login', [
            'email' => 'admin@test.com', 'password' => 'wrong-password',
        ])->assertStatus(401);

        $this->postJson('/api/v1/admin/login', [
            'email' => 'nobody@test.com', 'password' => 'password123',
        ])->assertStatus(401);
    }

    public function test_the_token_opens_the_admin_routes(): void
    {
        $token = $this->login();

        $this->asAdmin($token)->getJson('/api/v1/admin/me')
            ->assertOk()->assertJsonPath('data.user.email', 'admin@test.com');

        $this->asAdmin($token)->getJson('/api/v1/admin/charities')->assertOk();
    }

    public function test_the_legacy_header_still_works(): void
    {
        // Kept until every client has moved to /admin/login.
        $this->withHeader('X-Admin-Token', 'test-admin-token')
            ->getJson('/api/v1/admin/charities')->assertOk();
    }

    public function test_no_credentials_at_all_are_refused(): void
    {
        $this->getJson('/api/v1/admin/charities')->assertStatus(401);
        $this->withHeader('X-Admin-Token', 'wrong')->getJson('/api/v1/admin/charities')->assertStatus(401);
    }

    public function test_a_donor_token_is_not_an_admin_token(): void
    {
        $donorToken = $this->postJson('/api/v1/register/donor', [
            'name' => 'Ahmad', 'type' => 'restaurant', 'email' => 'donor@test.com',
            'phone' => '0999999999', 'password' => 'password123',
            'password_confirmation' => 'password123',
        ])->assertStatus(201)->json('data.token');

        // A perfectly valid Sanctum token that simply belongs to the wrong table.
        $this->asAdmin($donorToken)->getJson('/api/v1/admin/charities')->assertStatus(401);
    }

    public function test_logging_out_revokes_that_token_only(): void
    {
        $first  = $this->login();
        $second = $this->login();

        $this->asAdmin($first)->postJson('/api/v1/admin/logout')->assertOk();

        $this->asAdmin($first)->getJson('/api/v1/admin/me')->assertStatus(401);
        $this->asAdmin($second)->getJson('/api/v1/admin/me')->assertOk();
    }
}
