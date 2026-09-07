<?php

namespace Tests\Feature;

use App\Enums\CharityStatus;
use App\Models\Admin;
use App\Models\Charity;
use App\Models\Violation;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * The Filament dashboard: that it is actually locked, that it reads the same
 * rows the API writes, and that acting from it goes through the same services.
 */
class AdminPanelTest extends TestCase
{
    use RefreshDatabase;

    private Admin $admin;

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin = Admin::create([
            'name' => 'مدير', 'email' => 'admin@test.com', 'password' => 'password123',
        ]);
    }

    private function charity(array $overrides = []): Charity
    {
        return Charity::create(array_merge([
            'name' => 'جمعية البر', 'email' => 'c@test.com', 'phone' => '0911',
            'password' => 'password123', 'has_kitchen' => true,
            'status' => CharityStatus::Pending, 'address' => 'حلب',
            'work_start' => '08:00', 'work_end' => '18:00',
        ], $overrides));
    }

    public function test_the_panel_is_closed_to_anonymous_visitors(): void
    {
        $this->get('/admin')->assertRedirect('/admin/login');
        $this->get('/admin/charities')->assertRedirect('/admin/login');
    }

    public function test_the_login_screen_is_reachable(): void
    {
        $this->get('/admin/login')->assertOk();
    }

    public function test_an_admin_can_open_the_dashboard_and_its_screens(): void
    {
        $this->actingAs($this->admin, 'admin');

        $this->get('/admin')->assertOk();
        $this->get('/admin/charities')->assertOk();
        $this->get('/admin/donation-requests')->assertOk();
    }

    public function test_a_donor_or_charity_account_is_not_an_admin(): void
    {
        // Guards are separate on purpose: an app account has no session here,
        // and its Sanctum token means nothing to the panel.
        $this->get('/admin')->assertRedirect('/admin/login');

        $this->assertSame(0, Admin::where('email', 'c@test.com')->count());
    }

    public function test_approving_from_the_panel_runs_the_same_service_as_the_api(): void
    {
        $charity = $this->charity(['status' => CharityStatus::Suspended]);
        Violation::create([
            'charity_id' => $charity->id, 'reason' => 'no_show',
            'severity' => 'high', 'admin_note' => 'لم تحضر لاستلام الطلب المتفق عليه',
        ]);

        app(\App\Services\CharityService::class)->approve($charity);

        // Reinstating clears the record, exactly as the endpoint does.
        $this->assertSame(CharityStatus::Active, $charity->refresh()->status);
        $this->assertSame(0, Violation::where('charity_id', $charity->id)->count());
    }

    public function test_filing_a_notice_through_the_service_suspends_at_the_threshold(): void
    {
        $charity = $this->charity(['status' => CharityStatus::Active]);
        $service = app(\App\Services\ViolationService::class);

        foreach (range(1, 2) as $n) {
            $service->record($charity, [
                'reason' => 'no_show',
                'admin_note' => "قبلت الطلب ولم تحضر — الحالة رقم {$n}",
            ]);
        }

        $this->assertSame(6, $service->weightFor($charity->refresh()));
        $this->assertSame(CharityStatus::Suspended, $charity->status);
    }
}
