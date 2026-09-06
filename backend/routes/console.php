<?php

use App\Console\Commands\ExpireStaleDonations;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Time-driven donation transitions (pending -> expired, accepted -> no_show).
// In production this needs the standard cron: * * * * * php artisan schedule:run
Schedule::command(ExpireStaleDonations::class)->everyMinute();
