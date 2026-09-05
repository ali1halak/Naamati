<?php

use App\Http\Controllers\Api\Admin\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\Charity\CharityRequestController;
use App\Http\Controllers\Api\Donor\DonationRequestController;
use App\Http\Controllers\Api\FoodCategoryController;
use App\Http\Controllers\Api\NotificationController;
use Illuminate\Support\Facades\Route;

// Route ids are numeric. Without this a request for /requests/abc reaches the
// controller, fails to coerce "abc" into its int parameter, and surfaces as a
// 500 that leaks the class name — instead of a plain 404.
Route::prefix('v1')->where(['id' => '[0-9]+', 'charity' => '[0-9]+'])->group(function () {
    // Throttled: these are the only unauthenticated write endpoints, so they are
    // the ones worth brute-forcing. 5 attempts per minute per IP.
    Route::middleware('throttle:5,1')->group(function () {
        Route::post('/register/donor', [AuthController::class, 'registerDonor']);
        Route::post('/register/charity', [AuthController::class, 'registerCharity']);
        Route::post('/login', [AuthController::class, 'login']);
    });

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);
        Route::get('/food-categories', [FoodCategoryController::class, 'index']);

        // Shared by donors and charities — each only ever sees its own feed.
        Route::get('/notifications', [NotificationController::class, 'index']);
        Route::post('/notifications/{id}/read', [NotificationController::class, 'markRead']);

        // ---- Donor ----
        Route::middleware('type:donor')->prefix('donor')->group(function () {
            Route::get('/requests', [DonationRequestController::class, 'index']);
            Route::post('/requests', [DonationRequestController::class, 'store']);
            Route::get('/requests/{id}', [DonationRequestController::class, 'show']);
            Route::get('/requests/{id}/audit', [DonationRequestController::class, 'audit']);
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

            // Handover needs both sides: this is the charity's half, the donor
            // presses its own /donor/requests/{id}/confirm.
            Route::post('/requests/{id}/pickup', [CharityRequestController::class, 'pickup']);

            // Confirming the distribution closes the request; the beneficiary
            // numbers are a separate call so they can be filed later.
            Route::post('/requests/{id}/complete', [CharityRequestController::class, 'complete']);
            Route::post('/requests/{id}/impact', [CharityRequestController::class, 'impact']);
        });
    });

    // Admin — authenticated with the static X-Admin-Token header, not Sanctum.
    Route::middleware('admin.token')->prefix('admin')->group(function () {
        Route::get('/charities', [AdminController::class, 'charities']);
        Route::post('/charities/{charity}/approve', [AdminController::class, 'approve']);
        Route::post('/charities/{charity}/suspend', [AdminController::class, 'suspend']);
        Route::get('/notifications', [AdminController::class, 'notifications']);
        Route::post('/notifications/{id}/read', [AdminController::class, 'markNotificationRead']);
    });
});
