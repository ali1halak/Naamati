<?php

namespace Database\Seeders;

use App\Models\FoodCategory;
use Illuminate\Database\Seeder;

class FoodCategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['name_ar' => 'طعام مطبوخ جاهز',     'name_en' => 'Cooked / Ready',      'default_needs_cooking' => false],
            ['name_ar' => 'خضار وفواكه',          'name_en' => 'Fruits & Vegetables', 'default_needs_cooking' => false],
            ['name_ar' => 'مخبوزات وحلويات',      'name_en' => 'Bakery & Sweets',     'default_needs_cooking' => false],
            ['name_ar' => 'معلّبات وأطعمة جافة',  'name_en' => 'Canned & Dry',        'default_needs_cooking' => false],
            ['name_ar' => 'لحوم ودواجن نيئة',     'name_en' => 'Raw Meat & Poultry',  'default_needs_cooking' => true],
            ['name_ar' => 'حبوب نيئة',            'name_en' => 'Raw Grains',          'default_needs_cooking' => true],
            ['name_ar' => 'غير ذلك',              'name_en' => 'Other',               'default_needs_cooking' => false],
        ];

        // updateOrCreate keyed on name_en so re-seeding never duplicates rows.
        foreach ($categories as $category) {
            FoodCategory::updateOrCreate(
                ['name_en' => $category['name_en']],
                $category
            );
        }
    }
}
