<?php

namespace Database\Seeders;

use App\Enums\RequestStatus;
use App\Models\Charity;
use App\Models\DonationRequest;
use App\Models\Donor;
use App\Models\FoodCategory;
use Illuminate\Database\Seeder;

/**
 * Fake donation history for manual testing (pagination, filters, search).
 *
 * Gives every existing donor ~24 donations spread across statuses, categories
 * and creation dates. At most one `pending` per donor (never `accepted`) so
 * the "one in-flight request" rule stays satisfiable and the donor can still
 * create new donations from the app.
 *
 * Usage: php artisan db:seed --class=DonationRequestSeeder
 */
class DonationRequestSeeder extends Seeder
{
    public function run(): void
    {
        $categories = FoodCategory::all();
        $charityIds = Charity::pluck('id');

        if ($categories->isEmpty()) {
            $this->command->warn('No food categories found — run FoodCategorySeeder first.');

            return;
        }

        // Plain positive numbers (estimated people count) — matches the
        // create/update validation, which rejects free text.
        $quantities = ['12', '20', '8', '30', '15', '25', '40', '6'];
        $descriptions = [
            'أرز مع دجاج، محضّر اليوم', 'خضار طازجة من سلة اليوم',
            'معجنات متنوعة، خُبزت صباحاً', 'معلبات متنوعة لم تُفتح',
            'حلويات شرقية طازجة', 'شوربة وعدس مع خبز',
            'فواكه موسمية ممتازة', 'سلطات وطواجن نيئة جاهزة للطبخ',
        ];
        $addresses = [
            'دمشق - حي الشعلان', 'دمشق - المزة', 'ريف دمشق - جرمانا',
            'حلب - الفرقان', 'حمص - الوعر', 'لاذقية - الأمريكان',
        ];

        // Mostly terminal states so pagination/filtering can be exercised
        // without blocking the donor's ability to create new requests.
        $statusCycle = [
            RequestStatus::Completed,
            RequestStatus::PickedUp,
            RequestStatus::Expired,
            RequestStatus::Cancelled,
            RequestStatus::Completed,
            RequestStatus::NoShow,
            RequestStatus::Completed,
            RequestStatus::Expired,
        ];

        foreach (Donor::all() as $donor) {
            $existing = DonationRequest::where('donor_id', $donor->id)->count();
            if ($existing >= 20) {
                $this->command->line("Donor #{$donor->id} ({$donor->email}) already has {$existing} donations — skipped.");

                continue;
            }

            // One pending at most, and only when the donor has none in flight.
            $hasActive = DonationRequest::where('donor_id', $donor->id)
                ->whereIn('status', RequestStatus::blockingNewRequestValues())
                ->exists();

            for ($i = 0; $i < 24; $i++) {
                /** @var RequestStatus $status */
                $status = $i === 23 && ! $hasActive
                    ? RequestStatus::Pending
                    : $statusCycle[$i % count($statusCycle)];

                $createdAt = now()->subDays(random_int(1, 90))->subHours(random_int(0, 20));
                $charityId = in_array($status, [RequestStatus::PickedUp, RequestStatus::Completed, RequestStatus::NoShow], true)
                    && $charityIds->isNotEmpty()
                    ? $charityIds->random()
                    : null;

                DonationRequest::create([
                    'donor_id' => $donor->id,
                    'charity_id' => $charityId,
                    'food_category_id' => $categories->random()->id,
                    'needs_cooking' => (bool) random_int(0, 1),
                    'quantity_desc' => trim($quantities[array_rand($quantities)]),
                    'description' => $descriptions[array_rand($descriptions)],
                    'valid_until' => $createdAt->copy()->addDays(random_int(1, 3)),
                    'pickup_until' => $createdAt->copy()->addHours(random_int(4, 24)),
                    'pickup_address' => $addresses[array_rand($addresses)],
                    'contact_phone' => '09990001' . str_pad((string) random_int(0, 99), 2, '0', STR_PAD_LEFT),
                    'status' => $status->value,
                    'cancel_reason' => $status === RequestStatus::Cancelled
                        ? 'تغيّر موعد التوفر'
                        : null,
                    'cancelled_by' => $status === RequestStatus::Cancelled
                        ? \App\Enums\CancelledBy::Donor
                        : null,
                    'created_at' => $createdAt,
                    'updated_at' => $createdAt,
                ]);
            }

            $this->command->info("Donor #{$donor->id} ({$donor->email}): seeded 24 donations.");
        }
    }
}
