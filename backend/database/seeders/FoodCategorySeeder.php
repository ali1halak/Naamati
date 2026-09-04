<?php

namespace Database\Seeders;

use App\Models\FoodCategory;
use Illuminate\Database\Seeder;

class FoodCategorySeeder extends Seeder
{
    public function run(): void
    {
        // `icon` is a stable key, not a file — the app owns the artwork and
        // looks it up by this name. Renaming one is a breaking change.
        $categories = [
            ['name_ar' => 'طعام مطبوخ جاهز',     'name_en' => 'Cooked / Ready',      'icon' => 'cooked_ready',      'default_needs_cooking' => false],
            ['name_ar' => 'خضار وفواكه',          'name_en' => 'Fruits & Vegetables', 'icon' => 'fruits_vegetables', 'default_needs_cooking' => false],
            ['name_ar' => 'مخبوزات وحلويات',      'name_en' => 'Bakery & Sweets',     'icon' => 'bakery_sweets',     'default_needs_cooking' => false],
            ['name_ar' => 'معلّبات وأطعمة جافة',  'name_en' => 'Canned & Dry',        'icon' => 'canned_dry',        'default_needs_cooking' => false],
            ['name_ar' => 'لحوم ودواجن نيئة',     'name_en' => 'Raw Meat & Poultry',  'icon' => 'raw_meat',          'default_needs_cooking' => true],
            ['name_ar' => 'حبوب نيئة',            'name_en' => 'Raw Grains',          'icon' => 'raw_grains',        'default_needs_cooking' => true],
            ['name_ar' => 'غير ذلك',              'name_en' => 'Other',               'icon' => 'other',             'default_needs_cooking' => false],
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
