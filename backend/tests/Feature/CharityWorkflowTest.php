<?php

namespace Tests\Feature;

use App\Models\Charity;
use App\Models\DonationRequest;
use App\Models\FoodCategory;
use App\Models\Violation;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Tests\TestCase;

/**
 * The charity half of the platform: taking a request off the marketplace,
 * the two-sided handover, closing it out, and the compliance record.
 *
 * The donor suite covers the other half; these paths share DonationRequestService
 * and DonationRequestResource with it, so they need their own guard rails.
 */
class CharityWorkflowTest extends TestCase
{
    use RefreshDatabase;

    private string $donorToken;

    private string $charityToken;

    private Charity $charity;

    private FoodCategory $cooked;

    private FoodCategory $rawMeat;

    protected function setUp(): void
    {
        parent::setUp();

        // Mutation routes are throttled and the array cache lives for the whole
        // process — clear it so each test gets its own budget.
        Cache::clear();

        config(['services.admin.token' => 'test-admin-token']);

        $this->cooked = FoodCategory::create([
            'name_ar' => 'طعام مطبوخ جاهز', 'name_en' => 'Cooked', 'icon' => 'cooked_ready',
            'default_needs_cooking' => false,
        ]);
        $this->rawMeat = FoodCategory::create([
            'name_ar' => 'لحوم نيئة', 'name_en' => 'Raw Meat', 'icon' => 'raw_meat',
            'default_needs_cooking' => true,
        ]);

        $this->donorToken   = $this->registerDonor('donor@test.com');
        $this->charityToken = $this->registerCharity('charity@test.com', hasKitchen: true);
        $this->charity      = Charity::where('email', 'charity@test.com')->first();
        $this->approve($this->charity);
    }

    // ── Helpers ─────────────────────────────────────────────────────────────────

    private function registerDonor(string $email): string
    {
        return $this->postJson('/api/v1/register/donor', [
            'name' => 'Ahmad', 'type' => 'restaurant', 'email' => $email,
            'phone' => '0999999999', 'password' => 'password123',
            'password_confirmation' => 'password123',
        ])->assertStatus(201)->json('data.token');
    }

    private function registerCharity(string $email, bool $hasKitchen): string
    {
        return $this->postJson('/api/v1/register/charity', [
            'name' => 'جمعية البر', 'email' => $email, 'phone' => '0911111111',
            'password' => 'password123', 'password_confirmation' => 'password123',
            'has_kitchen' => $hasKitchen, 'address' => 'حلب',
            'work_start' => '08:00', 'work_end' => '18:00',
        ])->assertStatus(201)->json('data.token');
    }

    private function approve(Charity $charity): void
    {
        $this->asAdmin()
            ->postJson("/api/v1/admin/charities/{$charity->id}/approve")
            ->assertOk();
    }

    /**
     * Switching identity mid-test needs the resolved guard cleared: the test
     * app instance is reused across requests, so without this the previously
     * authenticated account answers for the next token too. Real requests each
     * get a fresh container and never see this.
     */
    private function actingWith(string $token): self
    {
        $this->app['auth']->forgetGuards();

        // Headers accumulate across requests, so an admin token set earlier
        // would still be attached and quietly authorise a charity call.
        $this->flushHeaders();

        return $this->withHeader('Authorization', 'Bearer ' . $token);
    }

    private function asCharity(?string $token = null): self
    {
        return $this->actingWith($token ?? $this->charityToken);
    }

    private function asDonor(): self
    {
        return $this->actingWith($this->donorToken);
    }

    private function asAdmin(): self
    {
        $this->app['auth']->forgetGuards();
        $this->flushHeaders();

        return $this->withHeader('X-Admin-Token', 'test-admin-token');
    }

    private function pending(array $overrides = []): DonationRequest
    {
        return DonationRequest::create(array_merge([
            'donor_id'         => 1,
            'food_category_id' => $this->cooked->id,
            'needs_cooking'    => false,
            'quantity_desc'    => '20 وجبة',
            'valid_until'      => now()->addDays(2),
            'pickup_until'     => now()->addDay(),
            'pickup_address'   => 'حلب - الفرقان',
            'contact_phone'    => '0999000111',
            'status'           => 'pending',
        ], $overrides));
    }

    /** Drives a request all the way to picked_up through both confirmations. */
    private function handedOver(): DonationRequest
    {
        $request = $this->pending();

        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/accept", ['eta_minutes' => 30])->assertOk();
        $this->asDonor()->postJson("/api/v1/donor/requests/{$request->id}/confirm")->assertOk();
        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/pickup")->assertOk();

        return $request->refresh();
    }

    // ── Marketplace ─────────────────────────────────────────────────────────────

    public function test_marketplace_hides_food_needing_a_kitchen_from_charities_without_one(): void
    {
        $this->pending(['food_category_id' => $this->rawMeat->id, 'needs_cooking' => true]);
        $this->pending();

        $noKitchen = $this->registerCharity('nokitchen@test.com', hasKitchen: false);
        $this->approve(Charity::where('email', 'nokitchen@test.com')->first());

        $this->asCharity()->getJson('/api/v1/charity/requests/available')
            ->assertOk()->assertJsonCount(2, 'data.data');

        $this->asCharity($noKitchen)->getJson('/api/v1/charity/requests/available')
            ->assertOk()->assertJsonCount(1, 'data.data');
    }

    public function test_marketplace_card_carries_the_display_fields_the_screen_needs(): void
    {
        $this->pending();

        $card = $this->asCharity()->getJson('/api/v1/charity/requests/available')
            ->assertOk()->json('data.data.0');

        $this->assertSame('طعام مطبوخ جاهز', $card['title']);
        $this->assertSame('cooked_ready', $card['category_icon']);
        $this->assertSame('حلب - الفرقان', $card['location_zone']);
        $this->assertNotEmpty($card['pickup_deadline']);

        // The donor's number stays private until a charity commits to coming.
        $this->assertArrayNotHasKey('contact_phone', $card);
    }

    public function test_a_pending_charity_cannot_reach_any_charity_endpoint(): void
    {
        $this->registerCharity('waiting@test.com', hasKitchen: true);
        $token = $this->postJson('/api/v1/login', [
            'email' => 'waiting@test.com', 'password' => 'password123',
        ])->json('data.token');

        $this->asCharity($token)->getJson('/api/v1/charity/requests/available')->assertStatus(403);
    }

    // ── Accept ──────────────────────────────────────────────────────────────────

    public function test_only_the_first_charity_wins_a_request(): void
    {
        $request = $this->pending();
        $second  = $this->registerCharity('second@test.com', hasKitchen: true);
        $this->approve(Charity::where('email', 'second@test.com')->first());

        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/accept", ['eta_minutes' => 30])->assertOk();
        $this->asCharity($second)->postJson("/api/v1/charity/requests/{$request->id}/accept", ['eta_minutes' => 30])
            ->assertStatus(422);
    }

    public function test_a_charity_without_a_kitchen_cannot_accept_food_that_needs_cooking(): void
    {
        $request   = $this->pending(['food_category_id' => $this->rawMeat->id, 'needs_cooking' => true]);
        $noKitchen = $this->registerCharity('nokitchen2@test.com', hasKitchen: false);
        $this->approve(Charity::where('email', 'nokitchen2@test.com')->first());

        $this->asCharity($noKitchen)->postJson("/api/v1/charity/requests/{$request->id}/accept", ['eta_minutes' => 30])
            ->assertStatus(422);
    }

    public function test_eta_must_be_within_range(): void
    {
        $request = $this->pending();

        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/accept", ['eta_minutes' => 9999])
            ->assertStatus(422)->assertJsonPath('success', false);
    }

    // ── Two-sided handover ──────────────────────────────────────────────────────

    public function test_one_side_alone_does_not_complete_the_handover(): void
    {
        $request = $this->pending();
        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/accept", ['eta_minutes' => 30])->assertOk();

        $this->asDonor()->postJson("/api/v1/donor/requests/{$request->id}/confirm")
            ->assertOk()
            ->assertJsonPath('data.status', 'accepted');

        $this->assertNotNull($request->refresh()->donor_confirmed_at);
        $this->assertNull($request->charity_confirmed_at);

        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/pickup")
            ->assertOk()
            ->assertJsonPath('data.status', 'picked_up');

        $this->assertNotNull($request->refresh()->picked_up_at);
    }

    public function test_a_charity_cannot_confirm_a_request_it_never_accepted(): void
    {
        $request = $this->pending();
        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/accept", ['eta_minutes' => 30])->assertOk();

        $other = $this->registerCharity('other@test.com', hasKitchen: true);
        $this->approve(Charity::where('email', 'other@test.com')->first());

        $this->asCharity($other)->postJson("/api/v1/charity/requests/{$request->id}/pickup")->assertStatus(422);
        $this->assertNull($request->refresh()->charity_confirmed_at);
    }

    public function test_confirming_twice_is_refused(): void
    {
        $request = $this->pending();
        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/accept", ['eta_minutes' => 30])->assertOk();

        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/pickup")->assertOk();
        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/pickup")->assertStatus(422);
    }

    // ── Closing out ─────────────────────────────────────────────────────────────

    public function test_distribution_cannot_be_confirmed_before_the_handover_is(): void
    {
        $request = $this->pending();
        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/accept", ['eta_minutes' => 30])->assertOk();

        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/complete")->assertStatus(422);
    }

    public function test_completing_and_then_filing_the_numbers_separately(): void
    {
        $request = $this->handedOver();

        // "تعبئة لاحقاً": the request closes without any numbers.
        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/complete")
            ->assertOk()->assertJsonPath('data.status', 'completed');

        $this->assertNull($request->refresh()->distribution);

        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/impact", [
            'families_count' => 5, 'individuals_count' => 25, 'area' => 'حي الفرقان',
        ])->assertStatus(201);

        $this->assertSame(5, $request->refresh()->distribution->families_count);
    }

    public function test_numbers_cannot_be_filed_before_the_distribution_is_confirmed(): void
    {
        $request = $this->handedOver();

        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/impact", [
            'families_count' => 5, 'individuals_count' => 25, 'area' => 'x',
        ])->assertStatus(422);
    }

    public function test_numbers_are_accepted_only_once(): void
    {
        $request = $this->handedOver();
        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/complete")->assertOk();

        $payload = ['families_count' => 5, 'individuals_count' => 25, 'area' => 'x'];
        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/impact", $payload)->assertStatus(201);
        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/impact", $payload)->assertStatus(422);
    }

    // ── History and audit ───────────────────────────────────────────────────────

    public function test_history_filters_by_status_and_rejects_an_unknown_one(): void
    {
        $done = $this->handedOver();
        $this->asCharity()->postJson("/api/v1/charity/requests/{$done->id}/complete")->assertOk();

        $open = $this->pending();
        $this->asCharity()->postJson("/api/v1/charity/requests/{$open->id}/accept", ['eta_minutes' => 30])->assertOk();

        $this->asCharity()->getJson('/api/v1/charity/requests?status=all')->assertOk()->assertJsonCount(2, 'data.data');
        $this->asCharity()->getJson('/api/v1/charity/requests?status=completed')->assertOk()->assertJsonCount(1, 'data.data');
        $this->asCharity()->getJson('/api/v1/charity/requests?status=nope')->assertStatus(422);
    }

    public function test_audit_view_is_grouped_and_scoped_to_the_charity_that_handled_it(): void
    {
        $request = $this->handedOver();
        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/complete")->assertOk();
        $this->asCharity()->postJson("/api/v1/charity/requests/{$request->id}/impact", [
            'families_count' => 4, 'individuals_count' => 20, 'area' => 'مخيم اليرموك',
        ])->assertStatus(201);

        $this->asCharity()->getJson("/api/v1/charity/requests/{$request->id}/details")
            ->assertOk()
            ->assertJsonPath('data.donor.name', 'Ahmad')
            ->assertJsonPath('data.donation.category', 'طعام مطبوخ جاهز')
            ->assertJsonPath('data.pickup.location', 'حلب - الفرقان')
            ->assertJsonPath('data.distribution.beneficiary_families', 4)
            ->assertJsonPath('data.distribution.distribution_zone', 'مخيم اليرموك');

        $other = $this->registerCharity('nosy@test.com', hasKitchen: true);
        $this->approve(Charity::where('email', 'nosy@test.com')->first());

        // 404, not 403 — another charity's ids are neither confirmed nor denied.
        $this->asCharity($other)->getJson("/api/v1/charity/requests/{$request->id}/details")->assertStatus(404);
    }

    // ── Compliance ──────────────────────────────────────────────────────────────

    public function test_a_clean_record_reports_zero_weight_and_the_threshold(): void
    {
        $this->asCharity()->getJson('/api/v1/charity/violations')
            ->assertOk()
            ->assertJsonCount(0, 'data.data')
            ->assertJsonPath('data.compliance.total_weight', 0)
            ->assertJsonPath('data.compliance.suspension_threshold', 6);
    }

    public function test_an_admin_notice_appears_on_the_charity_record(): void
    {
        $this->asAdmin()->postJson("/api/v1/admin/charities/{$this->charity->id}/violations", [
            'reason'     => 'late_pickup',
            'admin_note' => 'تأخر في الاستلام لأكثر من ساعتين عن الموعد المتفق عليه',
        ])->assertStatus(201)->assertJsonPath('data.title', 'تأخر في استلام الطلب');

        $this->asCharity()->getJson('/api/v1/charity/violations')
            ->assertOk()
            ->assertJsonCount(1, 'data.data')
            // late_pickup defaults to low, which weighs 1.
            ->assertJsonPath('data.compliance.total_weight', 1);
    }

    public function test_a_notice_needs_a_real_explanation(): void
    {
        $this->asAdmin()->postJson("/api/v1/admin/charities/{$this->charity->id}/violations", [
            'reason' => 'late_pickup', 'admin_note' => 'short',
        ])->assertStatus(422);

        $this->asAdmin()->postJson("/api/v1/admin/charities/{$this->charity->id}/violations", [
            'reason' => 'nonsense', 'admin_note' => 'سبب مفصل بما فيه الكفاية هنا',
        ])->assertStatus(422);
    }

    public function test_enough_weight_suspends_the_account_and_reinstating_clears_it(): void
    {
        // no_show defaults to high, which weighs 3; the threshold is 6.
        foreach (range(1, 2) as $n) {
            $this->asAdmin()->postJson("/api/v1/admin/charities/{$this->charity->id}/violations", [
                'reason' => 'no_show', 'admin_note' => "قبلت الطلب ولم تحضر لاستلامه — الحالة رقم {$n}",
            ])->assertStatus(201);
        }

        $this->assertSame(6, $this->charity->refresh()->violations()->count() * 3);
        $this->asCharity()->getJson('/api/v1/charity/requests/available')->assertStatus(403);

        $this->approve($this->charity);

        $this->assertSame(0, Violation::where('charity_id', $this->charity->id)->count());
        $this->asCharity()->getJson('/api/v1/charity/requests/available')->assertOk();
    }

    public function test_a_charity_cannot_file_a_notice_against_itself(): void
    {
        $this->asCharity()->postJson("/api/v1/admin/charities/{$this->charity->id}/violations", [
            'reason' => 'other', 'admin_note' => 'محاولة تسجيل مخالفة بدون صلاحية إدارية',
        ])->assertStatus(401);

        $this->assertSame(0, Violation::count());
    }
}
