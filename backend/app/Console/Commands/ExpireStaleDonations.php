<?php

namespace App\Console\Commands;

use App\Services\DonationRequestService;
use Illuminate\Console\Command;

/**
 * Flips time-expired donation requests to their terminal states:
 *
 *  - pending  past valid_until  -> expired
 *  - accepted past pickup_until -> no_show (charity takes a strike)
 *
 * Scheduled every minute in routes/console.php. In production this needs the
 * standard cron entry:  * * * * * php /path/to/artisan schedule:run
 */
class ExpireStaleDonations extends Command
{
    protected $signature = 'donations:expire-stale';

    protected $description = 'Expire pending requests past valid_until and mark accepted ones past pickup_until as no_show (with a charity strike)';

    public function handle(DonationRequestService $requests): int
    {
        $counts = $requests->expireStale();

        $this->info("expired: {$counts['expired']}, no_show: {$counts['no_show']}");

        return self::SUCCESS;
    }
}
