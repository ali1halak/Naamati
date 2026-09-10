<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * The charity's own address is now set from GPS/a map pin (same
     * professional-location pattern as a donor's pickup address) rather than
     * typed free text — `address` stays as the reverse-geocoded display
     * string, these are the coordinates behind it.
     */
    public function up(): void
    {
        Schema::table('charities', function (Blueprint $table) {
            $table->decimal('latitude', 10, 7)->nullable()->after('address');
            $table->decimal('longitude', 10, 7)->nullable()->after('latitude');
        });
    }

    public function down(): void
    {
        Schema::table('charities', function (Blueprint $table) {
            $table->dropColumn(['latitude', 'longitude']);
        });
    }
};
