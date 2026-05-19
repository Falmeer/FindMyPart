<?php

use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\AdminDashboardController;
use App\Http\Controllers\Admin\AdminGarageController;
use App\Http\Controllers\Admin\AdminLogController;
use App\Http\Controllers\Admin\AdminPostController;
use App\Http\Controllers\Admin\AdminProfileController;
use App\Http\Controllers\Admin\AdminReportController;
use App\Http\Controllers\Admin\AdminScrapyardController;
use App\Http\Controllers\Admin\AdminUserController;
use Illuminate\Support\Facades\Route;

// ── Public landing ───────────────────────────────────────────────────────────
Route::get('/', fn() => view('welcome'));

// ── Admin auth ───────────────────────────────────────────────────────────────
Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('login',  [AdminAuthController::class, 'showLogin'])->name('login');
    Route::post('login', [AdminAuthController::class, 'login']);
});

Route::post('admin/logout', [AdminAuthController::class, 'logout'])->name('admin.logout')->middleware('auth');

// ── Admin panel (auth + admin role) ─────────────────────────────────────────
Route::prefix('admin')->name('admin.')->middleware(['auth', 'admin'])->group(function () {

    // Dashboard
    Route::get('/', [AdminDashboardController::class, 'index'])->name('dashboard');

    // Users
    Route::prefix('users')->name('users.')->group(function () {
        Route::get('/',              [AdminUserController::class, 'index'])->name('index');
        Route::get('/banned',        [AdminUserController::class, 'bannedAccounts'])->name('banned');
        Route::get('/{user}',        [AdminUserController::class, 'show'])->name('show');
        Route::post('/{user}/ban',   [AdminUserController::class, 'ban'])->name('ban');
        Route::post('/{user}/unban', [AdminUserController::class, 'unban'])->name('unban');
        Route::delete('/{user}',     [AdminUserController::class, 'destroy'])->name('destroy');
    });

    // Garages
    Route::prefix('garages')->name('garages.')->group(function () {
        Route::get('/',                        [AdminGarageController::class, 'index'])->name('index');
        Route::get('/create',                  [AdminGarageController::class, 'create'])->name('create');
        Route::post('/',                       [AdminGarageController::class, 'store'])->name('store');
        Route::get('/{garage}',                [AdminGarageController::class, 'show'])->name('show');
        Route::get('/{garage}/edit',           [AdminGarageController::class, 'edit'])->name('edit');
        Route::put('/{garage}',                [AdminGarageController::class, 'update'])->name('update');
        Route::post('/{garage}/status',        [AdminGarageController::class, 'updateStatus'])->name('status');
        Route::delete('/{garage}',             [AdminGarageController::class, 'destroy'])->name('destroy');
    });

    // Scrapyards
    Route::prefix('scrapyards')->name('scrapyards.')->group(function () {
        Route::get('/',                          [AdminScrapyardController::class, 'index'])->name('index');
        Route::get('/create',                    [AdminScrapyardController::class, 'create'])->name('create');
        Route::post('/',                         [AdminScrapyardController::class, 'store'])->name('store');
        Route::get('/{scrapyard}',               [AdminScrapyardController::class, 'show'])->name('show');
        Route::get('/{scrapyard}/edit',          [AdminScrapyardController::class, 'edit'])->name('edit');
        Route::put('/{scrapyard}',               [AdminScrapyardController::class, 'update'])->name('update');
        Route::post('/{scrapyard}/status',       [AdminScrapyardController::class, 'updateStatus'])->name('status');
        Route::delete('/{scrapyard}',            [AdminScrapyardController::class, 'destroy'])->name('destroy');
    });

    // Posts moderation (spare parts + salvaged vehicles)
    Route::prefix('posts')->name('posts.')->group(function () {
        Route::get('/',                                          [AdminPostController::class, 'index'])->name('index');
        Route::post('/spare-parts/{sparePart}/toggle',           [AdminPostController::class, 'toggleSparePartActive'])->name('spare-parts.toggle');
        Route::delete('/spare-parts/{sparePart}',                [AdminPostController::class, 'destroySparePart'])->name('spare-parts.destroy');
        Route::post('/vehicles/{vehicle}/toggle',                [AdminPostController::class, 'toggleVehicleActive'])->name('vehicles.toggle');
        Route::delete('/vehicles/{vehicle}',                     [AdminPostController::class, 'destroyVehicle'])->name('vehicles.destroy');
    });

    // Reports
    Route::prefix('reports')->name('reports.')->group(function () {
        Route::get('/',                          [AdminReportController::class, 'index'])->name('index');
        Route::get('/{report}',                  [AdminReportController::class, 'show'])->name('show');
        Route::post('/{report}/resolve',         [AdminReportController::class, 'resolve'])->name('resolve');
        Route::post('/{report}/dismiss',         [AdminReportController::class, 'dismiss'])->name('dismiss');
    });

    // Activity logs
    Route::get('logs', [AdminLogController::class, 'index'])->name('logs.index');

    // Profile
    Route::prefix('profile')->name('profile.')->group(function () {
        Route::get('/',                  [AdminProfileController::class, 'edit'])->name('edit');
        Route::put('/',                  [AdminProfileController::class, 'update'])->name('update');
        Route::put('/password',          [AdminProfileController::class, 'changePassword'])->name('password');
    });
});
