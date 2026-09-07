<?php

namespace Tests\Feature;

use App\Services\TokenService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Laravel\Sanctum\PersonalAccessToken;
use Tests\TestCase;

/**
 * The access/refresh pair: what each half can do, what it cannot, and what
 * happens to a refresh token once it has been spent.
 */
class RefreshTokenTest extends TestCase
{
    use RefreshDatabase;

    private array $pair;

    protected function setUp(): void
    {
        parent::setUp();

        Cache::clear();

        $this->pair = $this->postJson('/api/v1/register/donor', [
            'name' => 'Ahmad', 'type' => 'restaurant', 'email' => 'donor@test.com',
            'phone' => '0999999999', 'password' => 'password123',
            'password_confirmation' => 'password123',
        ])->assertStatus(201)->json('data');
    }

    private function withBearer(string $token): self
    {
        $this->app['auth']->forgetGuards();
        $this->flushHeaders();

        return $this->withHeader('Authorization', 'Bearer ' . $token);
    }

    public function test_signing_in_returns_both_halves_and_the_legacy_field(): void
    {
        $this->assertArrayHasKey('access_token', $this->pair);
        $this->assertArrayHasKey('refresh_token', $this->pair);
        $this->assertSame('Bearer', $this->pair['token_type']);
        $this->assertSame(TokenService::ACCESS_TTL_MINUTES * 60, $this->pair['expires_in']);

        // Clients written against the old response keep working: `token` is
        // the access token under its previous name.
        $this->assertSame($this->pair['access_token'], $this->pair['token']);
    }

    public function test_the_access_token_opens_ordinary_routes(): void
    {
        $this->withBearer($this->pair['access_token'])
            ->getJson('/api/v1/me')->assertOk();
    }

    public function test_a_refresh_token_cannot_be_used_as_an_access_token(): void
    {
        // The whole point of splitting them: a leaked refresh token reads nothing.
        $this->withBearer($this->pair['refresh_token'])
            ->getJson('/api/v1/me')->assertStatus(403);
    }

    public function test_an_access_token_cannot_mint_a_new_pair(): void
    {
        $this->withBearer($this->pair['access_token'])
            ->postJson('/api/v1/refresh')->assertStatus(403);
    }

    public function test_refreshing_returns_a_working_new_pair(): void
    {
        $fresh = $this->withBearer($this->pair['refresh_token'])
            ->postJson('/api/v1/refresh')
            ->assertOk()
            ->json('data');

        $this->assertNotSame($this->pair['access_token'], $fresh['access_token']);
        $this->assertNotSame($this->pair['refresh_token'], $fresh['refresh_token']);

        $this->withBearer($fresh['access_token'])->getJson('/api/v1/me')->assertOk();
    }

    public function test_a_spent_refresh_token_is_dead(): void
    {
        $this->withBearer($this->pair['refresh_token'])->postJson('/api/v1/refresh')->assertOk();

        // Rotation: presenting the same one again fails, which is what makes a
        // copied token worthless once the real client has refreshed.
        $this->withBearer($this->pair['refresh_token'])->postJson('/api/v1/refresh')->assertStatus(401);
    }

    public function test_refreshing_retires_the_old_access_token_too(): void
    {
        $this->withBearer($this->pair['refresh_token'])->postJson('/api/v1/refresh')->assertOk();

        $this->withBearer($this->pair['access_token'])->getJson('/api/v1/me')->assertStatus(401);
    }

    public function test_both_halves_carry_an_expiry(): void
    {
        $access  = PersonalAccessToken::findToken($this->pair['access_token']);
        $refresh = PersonalAccessToken::findToken($this->pair['refresh_token']);

        $this->assertNotNull($access->expires_at);
        $this->assertNotNull($refresh->expires_at);

        // The short clock is the credential that travels on every request.
        $this->assertTrue($access->expires_at->lt($refresh->expires_at));
        $this->assertSame(['access'], $access->abilities);
        $this->assertSame(['refresh'], $refresh->abilities);
    }

    public function test_an_expired_access_token_is_refused(): void
    {
        $token = PersonalAccessToken::findToken($this->pair['access_token']);
        $token->forceFill(['expires_at' => now()->subMinute()])->save();

        $this->withBearer($this->pair['access_token'])->getJson('/api/v1/me')->assertStatus(401);

        // ...but the refresh token still buys a new one, which is the point.
        $this->withBearer($this->pair['refresh_token'])->postJson('/api/v1/refresh')->assertOk();
    }

    public function test_signing_out_kills_this_device_and_leaves_the_others(): void
    {
        $other = $this->postJson('/api/v1/login', [
            'email' => 'donor@test.com', 'password' => 'password123',
        ])->assertOk()->json('data');

        $this->withBearer($this->pair['access_token'])->postJson('/api/v1/logout')->assertOk();

        // Both halves of the signed-out pair are gone.
        $this->withBearer($this->pair['access_token'])->getJson('/api/v1/me')->assertStatus(401);
        $this->withBearer($this->pair['refresh_token'])->postJson('/api/v1/refresh')->assertStatus(401);

        // The other device is untouched.
        $this->withBearer($other['access_token'])->getJson('/api/v1/me')->assertOk();
    }

    public function test_admin_sign_in_issues_a_pair_as_well(): void
    {
        \App\Models\Admin::create([
            'name' => 'مدير', 'email' => 'admin@test.com', 'password' => 'password123',
        ]);

        $pair = $this->postJson('/api/v1/admin/login', [
            'email' => 'admin@test.com', 'password' => 'password123',
        ])->assertOk()->json('data');

        $this->assertArrayHasKey('refresh_token', $pair);
        $this->withBearer($pair['access_token'])->getJson('/api/v1/admin/me')->assertOk();
    }
}
