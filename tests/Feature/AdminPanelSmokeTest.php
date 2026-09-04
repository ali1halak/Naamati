<?php

namespace Tests\Feature;

use App\Models\Charity;
use App\Models\CharityViolation;
use App\Models\DonationOrder;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminPanelSmokeTest extends TestCase
{
    use RefreshDatabase;

    public function test_dashboard_loads_for_authenticated_user(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get('/admin')
            ->assertOk();
    }

    public function test_donation_orders_resource_pages_load(): void
    {
        $user = User::factory()->create();
        $charity = Charity::factory()->create();
        $order = DonationOrder::factory()->for($charity)->create();

        $this->actingAs($user)
            ->get('/admin/donation-orders')
            ->assertOk();

        $this->actingAs($user)
            ->get('/admin/donation-orders/'.$order->id)
            ->assertOk();

        $this->actingAs($user)
            ->get('/admin/donation-orders/'.$order->id.'/edit')
            ->assertOk();
    }

    public function test_charities_resource_pages_load(): void
    {
        $user = User::factory()->create();
        $charity = Charity::factory()->create();
        DonationOrder::factory(2)->for($charity)->create();
        CharityViolation::factory()->create(['charity_id' => $charity->id]);

        $this->actingAs($user)
            ->get('/admin/charities')
            ->assertOk();

        $this->actingAs($user)
            ->get('/admin/charities/'.$charity->id.'/edit')
            ->assertOk();
    }

    public function test_violations_resource_pages_load(): void
    {
        $user = User::factory()->create();
        $charity = Charity::factory()->create();
        CharityViolation::factory()->create(['charity_id' => $charity->id]);

        $this->actingAs($user)
            ->get('/admin/charity-violations')
            ->assertOk();
    }

    public function test_guest_is_redirected_to_login(): void
    {
        $this->get('/admin')->assertRedirect('/admin/login');
    }
}
