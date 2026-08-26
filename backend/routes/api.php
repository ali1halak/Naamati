<?php

use App\Http\Controllers\Api\Admin\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\FoodCategoryController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {

    // Throttled: these are the only unauthenticated write endpoints, so they are
    // the ones worth brute-forcing. 5 attempts per minute per IP.
    Route::middleware('throttle:5,1')->group(function () {
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/login', [AuthController::class, 'login']);
    });

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);
        Route::get('/food-categories', [FoodCategoryController::class, 'index']);
    });

    // Admin — authenticated with the static X-Admin-Token header, not Sanctum.
    Route::middleware('admin.token')->prefix('admin')->group(function () {
        Route::get('/charities', [AdminController::class, 'charities']);
        Route::post('/charities/{charity}/approve', [AdminController::class, 'approve']);
        Route::post('/charities/{charity}/suspend', [AdminController::class, 'suspend']);
    });
});
