<?php

namespace App\Providers;
use Illuminate\Support\Facades\URL;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        if (config('app.env') !== 'local' || str_contains(request()->headers->get('host'), 'ngrok-free.dev')) {
        URL::forceScheme('https');
    }
        //
    }
}
