<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FoodCategory;
use App\Traits\ApiResponse;

class FoodCategoryController extends Controller
{
    use ApiResponse;

    /**
     * Food categories for the "create donation request" screen.
     * Not paginated — this is a short, fixed reference list.
     */
    public function index()
    {
        return $this->ok(FoodCategory::orderBy('id')->get());
    }
}
