<?php

use App\Http\Controllers\Api\Admin\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\Charity\CharityRequestController;
use App\Http\Controllers\Api\Donor\DonationRequestController;
use App\Http\Controllers\Api\FoodCategoryController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::middleware('throttle:5,1')->group(function () {
        Route::post('/register/donor', [AuthController::class, 'registerDonor']);
        Route::post('/register/charity', [AuthController::class, 'registerCharity']);
        Route::post('/login', [AuthController::class, 'login']);
    });

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);
        Route::get('/food-categories', [FoodCategoryController::class, 'index']);

        Route::middleware('type:donor')->prefix('donor')->group(function () {
            Route::get('/requests', [DonationRequestController::class, 'index']);
            Route::post('/requests', [DonationRequestController::class, 'store']);
            Route::get('/requests/{id}', [DonationRequestController::class, 'show']);
            Route::post('/requests/{id}/cancel', [DonationRequestController::class, 'cancel']);
            Route::post('/requests/{id}/confirm', [DonationRequestController::class, 'confirm']);
            Route::post('/requests/{id}/rate', [DonationRequestController::class, 'rate']);
        });

        Route::middleware('type:charity')->prefix('charity')->group(function () {
            Route::get('/requests/available', [CharityRequestController::class, 'available']);
            Route::get('/requests', [CharityRequestController::class, 'index']);
            Route::get('/requests/{id}', [CharityRequestController::class, 'show']);
            Route::post('/requests/{id}/accept', [CharityRequestController::class, 'accept']);
        });
    });

    Route::middleware('admin.token')->prefix('admin')->group(function () {
        Route::get('/charities', [AdminController::class, 'charities']);
        Route::post('/charities/{charity}/approve', [AdminController::class, 'approve']);
        Route::post('/charities/{charity}/suspend', [AdminController::class, 'suspend']);
    });
});
