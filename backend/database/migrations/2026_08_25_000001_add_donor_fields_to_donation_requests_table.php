<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('donation_requests', function (Blueprint $table) {
            // Free-text approximate amount ("about 20 meals", "3 trays").
            // The donor only estimates; the charity reports the real numbers
            // after distributing (BR-9).
            $table->string('quantity_desc', 150)->after('needs_cooking');

            // Minutes the charity says it needs to arrive, set when accepting.
            $table->unsignedSmallInteger('eta_minutes')->nullable()->after('accepted_at');

            $table->string('cancel_reason', 255)->nullable()->after('confirmed_at');
        });
    }

    public function down(): void
    {
        Schema::table('donation_requests', function (Blueprint $table) {
            $table->dropColumn(['quantity_desc', 'eta_minutes', 'cancel_reason']);
        });
    }
};
