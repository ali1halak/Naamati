<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Pickup coordinates. The address string alone is not enough for a charity
     * to actually find the donor, and the app shows the point on a map.
     */
    public function up(): void
    {
        Schema::table('donation_requests', function (Blueprint $table) {
            $table->decimal('latitude', 10, 7)->after('pickup_address');
            $table->decimal('longitude', 10, 7)->after('latitude');
        });
    }

    public function down(): void
    {
        Schema::table('donation_requests', function (Blueprint $table) {
            $table->dropColumn(['latitude', 'longitude']);
        });
    }
};
