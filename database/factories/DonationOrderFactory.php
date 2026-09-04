<?php

namespace Database\Factories;

use App\Models\Charity;
use App\Models\DonationOrder;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<DonationOrder>
 */
class DonationOrderFactory extends Factory
{
    protected static array $foodTypes = [
        'وجبات جاهزة', 'مواد غذائية جافة', 'خضار وفواكه',
        'ألبان ومشتقاتها', 'خبز ومخبوزات',
    ];

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $status = $this->faker->randomElement(['pending', 'in_transit', 'delivered', 'cancelled']);
        $createdAt = $this->faker->dateTimeBetween('-30 days', 'now');

        return [
            'charity_id' => Charity::factory(),
            'food_type' => $this->faker->randomElement(static::$foodTypes),
            'quantity' => $this->faker->numberBetween(5, 500),
            'donor_name' => $this->faker->name(),
            'donor_phone' => $this->faker->numerify('+9627########'),
            'donor_rating' => $this->faker->randomFloat(1, 2, 5),
            'status' => $status,
            'delivered_at' => $status === 'delivered'
                ? $this->faker->dateTimeBetween($createdAt, 'now')
                : null,
            'created_at' => $createdAt,
            'updated_at' => $createdAt,
        ];
    }
}
