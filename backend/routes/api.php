<?php

use App\Http\Controllers\Api\Admin\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\Charity\CharityRequestController;
use App\Http\Controllers\Api\Donor\DonationRequestController;
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

        // ---- Donor ----
        Route::middleware('type:donor')->prefix('donor')->group(function () {
            Route::get('/requests', [DonationRequestController::class, 'index']);
            Route::post('/requests', [DonationRequestController::class, 'store']);
            Route::get('/requests/{id}', [DonationRequestController::class, 'show']);
            Route::post('/requests/{id}/cancel', [DonationRequestController::class, 'cancel']);
            Route::post('/requests/{id}/confirm', [DonationRequestController::class, 'confirm']);
            Route::post('/requests/{id}/rate', [DonationRequestController::class, 'rate']);
        });

        // ---- Charity (must be approved/active — enforced by the middleware) ----
        Route::middleware('type:charity')->prefix('charity')->group(function () {
            Route::get('/requests/available', [CharityRequestController::class, 'available']);
            Route::get('/requests', [CharityRequestController::class, 'index']);
            Route::get('/requests/{id}', [CharityRequestController::class, 'show']);
            Route::post('/requests/{id}/accept', [CharityRequestController::class, 'accept']);
        });
    });

    // Admin — authenticated with the static X-Admin-Token header, not Sanctum.
    Route::middleware('admin.token')->prefix('admin')->group(function () {
        Route::get('/charities', [AdminController::class, 'charities']);
        Route::post('/charities/{charity}/approve', [AdminController::class, 'approve']);
        Route::post('/charities/{charity}/suspend', [AdminController::class, 'suspend']);
    });
});
