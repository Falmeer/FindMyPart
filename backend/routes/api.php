<?php

use App\Http\Controllers\API\V1\AuthController;
use App\Http\Controllers\API\V1\VehicleController;
use App\Http\Controllers\API\V1\SparePartController;
use App\Http\Controllers\API\V1\GarageController;
use App\Http\Controllers\API\V1\ScrapyardController;
use App\Http\Controllers\API\V1\ScrapyardReviewController;
use App\Http\Controllers\API\V1\VehicleIssueController;
use App\Http\Controllers\API\V1\FavoriteController;
use App\Http\Controllers\API\V1\ReviewController;
use App\Http\Controllers\API\V1\AIController;
use App\Http\Controllers\API\V1\ChatController;
use App\Http\Controllers\API\V1\NotificationController;
use App\Http\Controllers\API\V1\PhoneVerificationController;
use App\Http\Controllers\API\V1\StorageController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {

    // ─── Public Auth Routes ───────────────────────────────────────────────────
    Route::prefix('auth')->group(function () {
        Route::post('register', [AuthController::class, 'register']);
        Route::post('login', [AuthController::class, 'login']);
        Route::post('forgot-password', [AuthController::class, 'forgotPassword']);
    });

    // ─── Public Listing Routes ────────────────────────────────────────────────
    Route::get('categories', fn() => response()->json([
        'success' => true,
        'data' => \App\Models\Category::orderBy('id')->get(['id', 'name', 'slug']),
    ]));

    Route::get('vehicles', [VehicleController::class, 'index']);
    Route::get('vehicles/{vehicle}', [VehicleController::class, 'show']);

    Route::get('spare-parts', [SparePartController::class, 'index']);
    Route::get('spare-parts/{sparePart}', [SparePartController::class, 'show']);

    Route::get('garages', [GarageController::class, 'index']);
    Route::get('garages/{garage}', [GarageController::class, 'show']);
    Route::get('garages/{garage}/reviews', [ReviewController::class, 'index']);

    Route::get('scrapyards', [ScrapyardController::class, 'index']);
    Route::get('scrapyards/{scrapyard}', [ScrapyardController::class, 'show']);
    Route::get('scrapyards/{scrapyard}/reviews', [ScrapyardReviewController::class, 'index']);

    // ─── Public Issues (read-only) ────────────────────────────────────────────
    Route::get('vehicle-issues/open', [VehicleIssueController::class, 'openIssues']);
    Route::get('vehicle-issues/{vehicleIssue}', [VehicleIssueController::class, 'show']);
    Route::get('vehicle-issues/{vehicleIssue}/comments', [VehicleIssueController::class, 'getComments']);

    // ─── Public AI Route ──────────────────────────────────────────────────────
    Route::post('ai/warning-light', [AIController::class, 'analyzeWarningLight']);

    // ─── Storage file proxy (serves public-disk files with CORS headers) ──────
    Route::get('files/{path}', [StorageController::class, 'serve'])->where('path', '.*');

    // ─── Authenticated Routes ─────────────────────────────────────────────────
    Route::middleware('auth:sanctum')->group(function () {

        // Auth
        Route::post('auth/logout', [AuthController::class, 'logout']);
        Route::get('auth/me', [AuthController::class, 'me']);
        Route::put('auth/profile', [AuthController::class, 'updateProfile']);
        Route::put('auth/password', [AuthController::class, 'changePassword']);
        Route::post('auth/phone/send-otp', [PhoneVerificationController::class, 'sendOtp']);
        Route::post('auth/phone/verify', [PhoneVerificationController::class, 'verifyOtp']);

        // Vehicles (create/update/delete — restricted by policy)
        Route::post('vehicles', [VehicleController::class, 'store']);
        Route::put('vehicles/{vehicle}', [VehicleController::class, 'update']);
        Route::delete('vehicles/{vehicle}', [VehicleController::class, 'destroy']);

        // Spare Parts
        Route::post('spare-parts', [SparePartController::class, 'store']);
        Route::put('spare-parts/{sparePart}', [SparePartController::class, 'update']);
        Route::delete('spare-parts/{sparePart}', [SparePartController::class, 'destroy']);

        // Garages
        Route::post('garages', [GarageController::class, 'store']);

        // Scrapyards
        Route::post('scrapyards', [ScrapyardController::class, 'store']);
        Route::post('scrapyards/{scrapyard}/reviews', [ScrapyardReviewController::class, 'store']);

        // Vehicle Issues (write operations only — reads are public above)
        Route::get('vehicle-issues', [VehicleIssueController::class, 'index']);
        Route::post('vehicle-issues', [VehicleIssueController::class, 'store']);
        Route::post('vehicle-issues/{vehicleIssue}/comments', [VehicleIssueController::class, 'storeComment']);

        // Favorites
        Route::get('favorites', [FavoriteController::class, 'index']);
        Route::post('favorites/toggle', [FavoriteController::class, 'toggle']);

        // Reviews
        Route::post('garages/{garage}/reviews', [ReviewController::class, 'store']);

        // Notifications
        Route::get('notifications', [NotificationController::class, 'index']);
        Route::get('notifications/unread-count', [NotificationController::class, 'unreadCount']);
        Route::post('notifications/{id}/read', [NotificationController::class, 'markRead']);
        Route::post('notifications/read-all', [NotificationController::class, 'markAllRead']);

        // Chat
        Route::get('conversations', [ChatController::class, 'conversations']);
        Route::post('conversations', [ChatController::class, 'findOrCreate']);
        Route::get('conversations/{chat}/messages', [ChatController::class, 'messages']);
        Route::post('conversations/{chat}/messages', [ChatController::class, 'send']);
    });
});
