<?php

namespace Database\Seeders;

use App\Models\Charity;
use App\Models\CharityViolation;
use App\Models\DonationOrder;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        User::firstOrCreate(
            ['email' => 'admin@naamaty.org'],
            [
                'name' => 'مدير النظام',
                'password' => bcrypt('password'),
            ]
        );

        $charities = Charity::factory(12)->create();

        $orders = collect();
        $charities->each(function (Charity $charity) use (&$orders) {
            $orders = $orders->merge(
                DonationOrder::factory(random_int(3, 8))
                    ->for($charity)
                    ->create()
            );
        });

        // Log a violation for a sample of orders, each tied back to its order's charity.
        $orders->random(min(18, $orders->count()))->each(function (DonationOrder $order) {
            CharityViolation::factory()->create([
                'charity_id' => $order->charity_id,
                'order_id' => $order->id,
            ]);
        });
    }
}
