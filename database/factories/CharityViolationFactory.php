<?php

namespace Database\Factories;

use App\Models\Charity;
use App\Models\CharityViolation;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<CharityViolation>
 */
class CharityViolationFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'charity_id' => Charity::factory(),
            'order_id' => null,
            'reason' => $this->faker->randomElement(['delay', 'storage', 'hygiene']),
            'severity' => $this->faker->randomElement(['low', 'medium', 'high']),
            'notes' => $this->faker->sentence(),
        ];
    }
}
