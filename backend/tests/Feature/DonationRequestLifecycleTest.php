<?php

namespace Tests\Feature;

use App\Console\Commands\ExpireStaleDonations;
use App\Models\DonationRequest;
use App\Models\FoodCategory;
use App\Models\Strike;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

/**
 * Critical donor-request paths: search (incl. custom_category), the dual
 * cancel paths with their distinct labels, the pending-only edit guard, and
 * the authored-field sanitisation (title spoofing + cooking-state forcing).
 */
class DonationRequestLifecycleTest extends TestCase
{
    use RefreshDatabase;

    private string $donorToken;

    private FoodCategory $vegetables;

    private FoodCategory $meat;

    private FoodCategory $other;

    protected function setUp(): void
    {
        parent::setUp();

        // The mutation routes are throttled and the array cache persists for
        // the whole process — clear it so each test starts its own budget.
        \Illuminate\Support\Facades\Cache::clear();

        // The admin middleware refuses every request when no token is
        // configured — give the tests a known one.
        config(['services.admin.token' => 'test-admin-token']);

        foreach ([
            ['name_ar' => 'خضار وفواكه', 'name_en' => 'Fruits & Vegetables', 'icon' => 'fruits_vegetables', 'default_needs_cooking' => false],
            ['name_ar' => 'لحوم نيئة', 'name_en' => 'Raw Meat', 'icon' => 'raw_meat', 'default_needs_cooking' => true],
            ['name_ar' => 'غير ذلك', 'name_en' => 'Other', 'icon' => 'other', 'default_needs_cooking' => false],
        ] as $category) {
            FoodCategory::create($category);
        }

        $this->vegetables = FoodCategory::where('icon', 'fruits_vegetables')->first();
        $this->meat = FoodCategory::where('icon', 'raw_meat')->first();
        $this->other = FoodCategory::where('icon', 'other')->first();

        $this->donorToken = $this->registerDonor();
    }

    // ── Helpers ─────────────────────────────────────────────────────────────────

    private function registerDonor(): string
    {
        return $this->postJson('/api/v1/register/donor', [
            'name' => 'Ahmad',
            'type' => 'individual',
            'email' => 'donor@test.com',
            'phone' => '0999999999',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ])->assertStatus(201)->json('data.token');
    }

    private function createPending(array $overrides = []): DonationRequest
    {
        return DonationRequest::create(array_merge([
            'donor_id' => 1,
            'food_category_id' => $this->vegetables->id,
            'needs_cooking' => false,
            'quantity_desc' => '10',
            'valid_until' => now()->addDays(2),
            'pickup_until' => now()->addDay(),
            'pickup_address' => 'Aleppo',
            'contact_phone' => '0999000111',
            'status' => 'pending',
        ], $overrides));
    }

    // ── Search ──────────────────────────────────────────────────────────────────

    public function test_search_matches_custom_category_name(): void
    {
        $this->createPending([
            'food_category_id' => $this->other->id,
            'custom_category' => 'مربى منزلي',
        ]);
        $this->createPending(['description' => 'أرز مع دجاج']);

        $this->withToken($this->donorToken)
            ->getJson('/api/v1/donor/requests?search='.urlencode('مربى'))
            ->assertStatus(200)
            ->assertJsonCount(1, 'data.data')
            ->assertJsonPath('data.data.0.title', 'مربى منزلي');
    }

    public function test_search_matches_description_and_returns_empty_for_unknown(): void
    {
        $this->createPending(['description' => 'أرز مع دجاج']);

        $this->withToken($this->donorToken)
            ->getJson('/api/v1/donor/requests?search='.urlencode('دجاج'))
            ->assertStatus(200)
            ->assertJsonCount(1, 'data.data');

        $this->withToken($this->donorToken)
            ->getJson('/api/v1/donor/requests?search=zzz-none')
            ->assertStatus(200)
            ->assertJsonCount(0, 'data.data');
    }

    // ── Dual cancel paths ───────────────────────────────────────────────────────

    public function test_donor_cancel_sets_donor_label(): void
    {
        $request = $this->createPending();

        $this->withToken($this->donorToken)
            ->postJson("/api/v1/donor/requests/{$request->id}/cancel", [
                'reason' => 'لا أحتاجه',
            ])
            ->assertStatus(200)
            ->assertJsonPath('data.status', 'cancelled')
            ->assertJsonPath('data.cancelled_by', 'donor')
            ->assertJsonPath('data.status_label', 'ألغاه المتبرع');
    }

    public function test_admin_cancel_sets_admin_label_and_is_rejected_on_terminal(): void
    {
        $request = $this->createPending();

        $this->postJson("/api/v1/admin/requests/{$request->id}/cancel", [
            'reason' => 'طلب وهمي',
        ], ['X-Admin-Token' => 'test-admin-token'])
            ->assertStatus(200)
            ->assertJsonPath('data.status', 'cancelled')
            ->assertJsonPath('data.cancelled_by', 'admin')
            ->assertJsonPath('data.status_label', 'ألغته الإدارة');

        // Terminal states can never be cancelled again.
        $this->postJson("/api/v1/admin/requests/{$request->id}/cancel", [], [
            'X-Admin-Token' => 'test-admin-token',
        ])->assertStatus(422);
    }

    // ── Pending-only edit guard ─────────────────────────────────────────────────

    public function test_donor_can_edit_pending_request(): void
    {
        $request = $this->createPending();

        $this->withToken($this->donorToken)
            ->putJson("/api/v1/donor/requests/{$request->id}", [
                'food_category_id' => $this->vegetables->id,
                'needs_cooking' => false,
                'quantity_desc' => 25,
                'valid_until' => now()->addDays(3)->format('Y-m-d H:i:s'),
                'pickup_until' => now()->addDays(2)->format('Y-m-d H:i:s'),
                'pickup_address' => 'Aleppo - Al-Furqan',
                'contact_phone' => '0999000111',
            ])
            ->assertStatus(200)
            ->assertJsonPath('data.quantity_desc', '25');
    }

    public function test_edit_is_rejected_once_not_pending(): void
    {
        $request = $this->createPending(['status' => 'accepted']);

        $this->withToken($this->donorToken)
            ->putJson("/api/v1/donor/requests/{$request->id}", [
                'food_category_id' => $this->vegetables->id,
                'quantity_desc' => 25,
                'valid_until' => now()->addDays(3)->format('Y-m-d H:i:s'),
                'pickup_until' => now()->addDays(2)->format('Y-m-d H:i:s'),
                'pickup_address' => 'Aleppo',
                'contact_phone' => '0999000111',
            ])
            ->assertStatus(422)
            ->assertJsonPath('errors.status.0', 'Only pending requests can be edited');
    }

    public function test_edit_of_another_donors_request_is_404(): void
    {
        $otherDonor = \App\Models\Donor::create([
            'name' => 'Other',
            'type' => 'individual',
            'email' => 'other@test.com',
            'phone' => '0988888888',
            'password' => 'password123',
        ]);
        $request = $this->createPending(['donor_id' => $otherDonor->id]);

        $this->withToken($this->donorToken)
            ->putJson("/api/v1/donor/requests/{$request->id}", [
                'food_category_id' => $this->vegetables->id,
                'quantity_desc' => 25,
                'valid_until' => now()->addDays(3)->format('Y-m-d H:i:s'),
                'pickup_until' => now()->addDays(2)->format('Y-m-d H:i:s'),
                'pickup_address' => 'Aleppo',
                'contact_phone' => '0999000111',
            ])
            ->assertStatus(404);
    }

    // ── Image editing ───────────────────────────────────────────────────────────

    /**
     * Multipart edit with method spoofing: removes one existing photo and
     * appends a new one, keeping the others in order.
     */
    public function test_edit_can_remove_and_add_images(): void
    {
        Storage::fake('public');
        $request = $this->createPending();
        $kept = $request->images()->create([
            'path' => UploadedFile::fake()->image('kept.jpg')->store('donation-images', 'public'),
            'sort_order' => 0,
        ]);
        $removed = $request->images()->create([
            'path' => UploadedFile::fake()->image('removed.jpg')->store('donation-images', 'public'),
            'sort_order' => 1,
        ]);

        $this->withToken($this->donorToken)
            ->post("/api/v1/donor/requests/{$request->id}", [
                '_method' => 'PUT',
                'food_category_id' => $this->vegetables->id,
                'needs_cooking' => 'false',
                'quantity_desc' => '10',
                'valid_until' => now()->addDays(3)->format('Y-m-d H:i:s'),
                'pickup_until' => now()->addDays(2)->format('Y-m-d H:i:s'),
                'pickup_address' => 'Aleppo',
                'contact_phone' => '0999000111',
                'removed_image_ids' => [(string) $removed->id],
                'images' => [UploadedFile::fake()->image('new.jpg')],
            ], ['content-type' => 'multipart/form-data'])
            ->assertStatus(200);

        $request->refresh()->load('images');
        // The removed row is gone, the kept one stays and the new file is
        // appended after it in upload order.
        $this->assertSame(
            [$kept->id, $request->images->last()->id],
            $request->images->pluck('id')->all()
        );
        // The dropped photo's file is gone from the disk, the kept one is not.
        Storage::disk('public')->assertMissing($removed->path);
        Storage::disk('public')->assertExists($kept->path);
    }

    public function test_edit_rejects_removed_image_id_from_another_request(): void
    {
        Storage::fake('public');
        $foreign = $this->createPending();
        $foreignImage = $foreign->images()->create([
            'path' => UploadedFile::fake()->image('foreign.jpg')->store('donation-images', 'public'),
            'sort_order' => 0,
        ]);
        $request = $this->createPending();

        $this->withToken($this->donorToken)
            ->post("/api/v1/donor/requests/{$request->id}", [
                '_method' => 'PUT',
                'food_category_id' => $this->vegetables->id,
                'quantity_desc' => '10',
                'valid_until' => now()->addDays(3)->format('Y-m-d H:i:s'),
                'pickup_until' => now()->addDays(2)->format('Y-m-d H:i:s'),
                'pickup_address' => 'Aleppo',
                'contact_phone' => '0999000111',
                'removed_image_ids' => [(string) $foreignImage->id],
            ], ['content-type' => 'multipart/form-data'])
            ->assertStatus(422)
            ->assertJsonPath('errors.removed_image_ids.0', 'إحدى الصور المحددة للحذف لا تنتمي إلى هذا الطلب.');
    }

    public function test_edit_rejects_more_than_four_images_in_total(): void
    {
        Storage::fake('public');
        $request = $this->createPending();
        for ($i = 0; $i < 4; $i++) {
            $request->images()->create([
                'path' => UploadedFile::fake()->image("photo-{$i}.jpg")->store('donation-images', 'public'),
                'sort_order' => $i,
            ]);
        }

        $this->withToken($this->donorToken)
            ->post("/api/v1/donor/requests/{$request->id}", [
                '_method' => 'PUT',
                'food_category_id' => $this->vegetables->id,
                'quantity_desc' => '10',
                'valid_until' => now()->addDays(3)->format('Y-m-d H:i:s'),
                'pickup_until' => now()->addDays(2)->format('Y-m-d H:i:s'),
                'pickup_address' => 'Aleppo',
                'contact_phone' => '0999000111',
                'images' => [UploadedFile::fake()->image('one-more.jpg')],
            ], ['content-type' => 'multipart/form-data'])
            ->assertStatus(422)
            ->assertJsonPath('errors.images.0', 'لا يمكن إرفاق أكثر من 4 صور.');
    }

    // ── Authored-field sanitisation ─────────────────────────────────────────────

    public function test_custom_category_is_dropped_for_real_categories(): void
    {
        $response = $this->withToken($this->donorToken)
            ->postJson('/api/v1/donor/requests', [
                'food_category_id' => $this->vegetables->id,
                'quantity_desc' => 10,
                'custom_category' => 'آيفون 15',
                'valid_until' => now()->addDays(2)->format('Y-m-d H:i:s'),
                'pickup_until' => now()->addDay()->format('Y-m-d H:i:s'),
                'pickup_address' => 'Aleppo',
                'contact_phone' => '0999000111',
            ])
            ->assertStatus(201);

        $this->assertDatabaseHas('donation_requests', [
            'id' => $response->json('data.id'),
            'custom_category' => null,
        ]);
    }

    public function test_cooking_state_is_forced_from_category_default(): void
    {
        // Raw meat defaults to needs_cooking=true — a spoofed false is ignored.
        $response = $this->withToken($this->donorToken)
            ->postJson('/api/v1/donor/requests', [
                'food_category_id' => $this->meat->id,
                'needs_cooking' => false,
                'quantity_desc' => 7,
                'valid_until' => now()->addDays(2)->format('Y-m-d H:i:s'),
                'pickup_until' => now()->addDay()->format('Y-m-d H:i:s'),
                'pickup_address' => 'Aleppo',
                'contact_phone' => '0999000111',
            ])
            ->assertStatus(201)
            ->assertJsonPath('data.needs_cooking', true);

        // Free the one-active-request lock, then check "غير ذلك" keeps the
        // donor's own choice.
        DonationRequest::whereKey($response->json('data.id'))->delete();

        $this->withToken($this->donorToken)
            ->postJson('/api/v1/donor/requests', [
                'food_category_id' => $this->other->id,
                'needs_cooking' => true,
                'quantity_desc' => 7,
                'custom_category' => 'مربى منزلي',
                'valid_until' => now()->addDays(2)->format('Y-m-d H:i:s'),
                'pickup_until' => now()->addDay()->format('Y-m-d H:i:s'),
                'pickup_address' => 'Aleppo',
                'contact_phone' => '0999000111',
            ])
            ->assertStatus(201)
            ->assertJsonPath('data.needs_cooking', true);
    }

    public function test_other_category_requires_custom_name(): void
    {
        $this->withToken($this->donorToken)
            ->postJson('/api/v1/donor/requests', [
                'food_category_id' => $this->other->id,
                'quantity_desc' => 7,
                'valid_until' => now()->addDays(2)->format('Y-m-d H:i:s'),
                'pickup_until' => now()->addDay()->format('Y-m-d H:i:s'),
                'pickup_address' => 'Aleppo',
                'contact_phone' => '0999000111',
            ])
            ->assertStatus(422)
            ->assertJsonPath('errors.custom_category.0', 'يرجى توضيح نوع الطعام عند اختيار "غير ذلك".');
    }

    public function test_daily_cap_of_five_posts_per_day(): void
    {
        $payload = [
            'food_category_id' => $this->vegetables->id,
            'quantity_desc' => 10,
            'valid_until' => now()->addDays(2)->format('Y-m-d H:i:s'),
            'pickup_until' => now()->addDay()->format('Y-m-d H:i:s'),
            'pickup_address' => 'Aleppo',
            'contact_phone' => '0999000111',
        ];

        for ($i = 0; $i < 5; $i++) {
            $this->withToken($this->donorToken)
                ->postJson('/api/v1/donor/requests', $payload)
                ->assertStatus(201);
        }

        // 6th create of the same day is refused, even though all five are
        // still pending (the old one-at-a-time lock is gone).
        $this->withToken($this->donorToken)
            ->postJson('/api/v1/donor/requests', $payload)
            ->assertStatus(422)
            ->assertJsonPath('errors.daily_limit.0',
                'وصلت إلى الحد الأقصى 5 طلبات في اليوم — يمكنك النشر مجدداً غداً.');
    }

    public function test_valid_until_cannot_be_more_than_30_days_out(): void
    {
        $this->withToken($this->donorToken)
            ->postJson('/api/v1/donor/requests', [
                'food_category_id' => $this->vegetables->id,
                'quantity_desc' => 10,
                'valid_until' => now()->addDays(31)->format('Y-m-d H:i:s'),
                'pickup_until' => now()->addDays(2)->format('Y-m-d H:i:s'),
                'pickup_address' => 'Aleppo',
                'contact_phone' => '0999000111',
            ])
            ->assertStatus(422)
            ->assertJsonPath(
                'errors.valid_until.0',
                'يجب ألا يتجاوز وقت انتهاء الصلاحية 30 يوماً من الآن.',
            );

        // 29 days out is fine.
        $this->withToken($this->donorToken)
            ->postJson('/api/v1/donor/requests', [
                'food_category_id' => $this->vegetables->id,
                'quantity_desc' => 10,
                'valid_until' => now()->addDays(29)->format('Y-m-d H:i:s'),
                'pickup_until' => now()->addDays(2)->format('Y-m-d H:i:s'),
                'pickup_address' => 'Aleppo',
                'contact_phone' => '0999000111',
            ])
            ->assertStatus(201);
    }

    public function test_quantity_must_be_a_positive_integer(): void
    {
        $payload = [
            'food_category_id' => $this->vegetables->id,
            'valid_until' => now()->addDays(2)->format('Y-m-d H:i:s'),
            'pickup_until' => now()->addDay()->format('Y-m-d H:i:s'),
            'pickup_address' => 'Aleppo',
            'contact_phone' => '0999000111',
        ];

        foreach (['-5', 'تكفي 10', '0'] as $bad) {
            $this->withToken($this->donorToken)
                ->postJson('/api/v1/donor/requests', $payload + ['quantity_desc' => $bad])
                ->assertStatus(422);
        }
    }

    // ── Time-driven transitions ─────────────────────────────────────────────────

    public function test_expire_command_moves_stale_requests(): void
    {
        $charity = \App\Models\Charity::create([
            'name' => 'Al-Birr',
            'email' => 'charity@test.com',
            'phone' => '0911111111',
            'password' => 'password123',
            'has_kitchen' => true,
            'address' => 'Aleppo',
            'work_start' => '08:00',
            'work_end' => '16:00',
            'status' => 'active',
        ]);

        $stalePending = $this->createPending(['valid_until' => now()->subDay()]);
        $staleAccepted = $this->createPending([
            'status' => 'accepted',
            'charity_id' => $charity->id,
            'valid_until' => now()->addDay(),
            'pickup_until' => now()->subDay(),
        ]);

        Artisan::call(ExpireStaleDonations::class);

        $this->assertDatabaseHas('donation_requests', [
            'id' => $stalePending->id,
            'status' => 'expired',
        ]);
        $this->assertDatabaseHas('donation_requests', [
            'id' => $staleAccepted->id,
            'status' => 'no_show',
        ]);
        $this->assertDatabaseHas('violations', [
            'donation_request_id' => $staleAccepted->id,
            'reason' => 'no_show',
        ]);

        // Fresh requests are untouched.
        $this->createPending();
        Artisan::call(ExpireStaleDonations::class);
        $this->assertEquals(1, DonationRequest::where('status', 'pending')->count());
    }
}
