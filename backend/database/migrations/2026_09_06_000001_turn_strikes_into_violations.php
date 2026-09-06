<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * `strikes` becomes `violations`.
 *
 * The table was only ever going to hold no-shows, but the compliance screen
 * shows every kind of notice an admin files — late pickups, quantity
 * mismatches — and calls them مخالفات. One name for one record beats a table
 * called strikes feeding a screen called violations.
 *
 * Safe to rename outright: nothing has ever written a row.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::rename('strikes', 'violations');

        // SQLite (the test database) has no MODIFY/ENUM — its reason column is
        // plain text and accepts the new values as-is.
        if (DB::getDriverName() === 'sqlite') {
            Schema::table('violations', function (Blueprint $table) {
                $table->enum('severity', ['low', 'medium', 'high'])->default('medium')->after('reason');
                $table->text('admin_note')->nullable()->after('severity');
                $table->dropColumn('note');
            });

            return;
        }

        // MySQL needs the enum widened before rows can use the new values.
        DB::statement("ALTER TABLE violations MODIFY reason
            ENUM('no_show','late_pickup','quantity_mismatch','impact_mismatch','other')
            NOT NULL DEFAULT 'no_show'");

        Schema::table('violations', function (Blueprint $table) {
            $table->enum('severity', ['low', 'medium', 'high'])->default('medium')->after('reason');

            // The admin's explanation, shown to the charity as-is. `text`
            // because these run to a couple of sentences.
            $table->text('admin_note')->nullable()->after('severity');
        });

        Schema::table('violations', function (Blueprint $table) {
            $table->dropColumn('note');
        });
    }

    public function down(): void
    {
        if (DB::getDriverName() === 'sqlite') {
            Schema::table('violations', function (Blueprint $table) {
                $table->string('note', 255)->nullable();
                $table->dropColumn(['severity', 'admin_note']);
            });

            return;
        }

        DB::statement("ALTER TABLE violations MODIFY reason ENUM('no_show') NOT NULL DEFAULT 'no_show'");

        Schema::rename('violations', 'strikes');
    }
};
