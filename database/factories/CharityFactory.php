<?php

namespace Database\Factories;

use App\Models\Charity;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Charity>
 */
class CharityFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    protected static array $regions = [
        'عمّان', 'إربد', 'الزرقاء', 'الكرك', 'العقبة', 'المفرق', 'مادبا',
    ];

    protected static array $namePrefixes = [
        'جمعية الخير', 'جمعية العطاء', 'مؤسسة الأمل', 'جمعية البركة',
        'جمعية الرحمة', 'مؤسسة الغد المشرق', 'جمعية النور', 'جمعية الإحسان',
    ];

    public function definition(): array
    {
        $name = $this->faker->randomElement(static::$namePrefixes)
            .' - '.$this->faker->unique()->city();

        return [
            'name' => $name,
            'logo_path' => null,
            'region' => $this->faker->randomElement(static::$regions),
            'phone' => $this->faker->numerify('+9627########'),
            'email' => $this->faker->unique()->safeEmail(),
            'active' => $this->faker->boolean(85),
            'rating' => $this->faker->randomFloat(1, 3, 5),
        ];
    }
}
