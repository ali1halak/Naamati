<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * How to actually reach the donor: "call 15 minutes before", "the side door
 * behind the mosque". Distinct from `description`, which is about the food.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('donation_requests', function (Blueprint $table) {
            $table->string('pickup_notes', 255)->nullable()->after('pickup_address');
        });
    }

    public function down(): void
    {
        Schema::table('donation_requests', function (Blueprint $table) {
            $table->dropColumn('pickup_notes');
        });
    }
};
