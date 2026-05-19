<?php

namespace App\Providers;

use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void {}

    public function boot(): void
    {
        // Allow Flutter (Bearer token) to authenticate private WebSocket channels
        Broadcast::routes(['middleware' => ['auth:sanctum']]);
    }
}
