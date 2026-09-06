<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Distinguish who cancelled a request — the donor (voluntary) or the admin
 * (moderation of fake/invalid requests). Null for every other status.
 * Existing cancelled rows were only cancellable by donors, so backfill them.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('donation_requests', function (Blueprint $table) {
            $table->enum('cancelled_by', ['donor', 'admin'])
                ->nullable()
                ->after('cancel_reason');
        });

        DB::table('donation_requests')
            ->where('status', 'cancelled')
            ->whereNull('cancelled_by')
            ->update(['cancelled_by' => 'donor']);
    }

    public function down(): void
    {
        Schema::table('donation_requests', function (Blueprint $table) {
            $table->dropColumn('cancelled_by');
        });
    }
};
