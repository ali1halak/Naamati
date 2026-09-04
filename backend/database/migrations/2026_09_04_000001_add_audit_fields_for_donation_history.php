<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Fields the donation history and audit screens need.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('distributions', function (Blueprint $table) {
            // Free-text remark from the charity: "handed out at the mosque
            // after Friday prayer", "two boxes were spoiled", and so on.
            $table->text('notes')->nullable()->after('area');
        });

        Schema::table('food_categories', function (Blueprint $table) {
            // A stable key the app maps to its own asset, e.g. "family_meals".
            // Not a URL: the icon set belongs to the client, not the API.
            $table->string('icon', 40)->default('other')->after('name_en');
        });

        Schema::table('donation_requests', function (Blueprint $table) {
            // Distinct from confirmed_at, which marks the donor's handover.
            // This one marks the charity filing its distribution numbers —
            // the moment the request is genuinely finished.
            $table->timestamp('completed_at')->nullable()->after('confirmed_at');
        });
    }

    public function down(): void
    {
        Schema::table('distributions', fn (Blueprint $table) => $table->dropColumn('notes'));
        Schema::table('food_categories', fn (Blueprint $table) => $table->dropColumn('icon'));
        Schema::table('donation_requests', fn (Blueprint $table) => $table->dropColumn('completed_at'));
    }
};
