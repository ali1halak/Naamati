<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * `published` is renamed to `pending` so the first state matches the name
     * the app documentation and the mobile client already use. Done in three
     * steps — widen the enum, move the rows, narrow it again — so it stays
     * safe even once the table holds data.
     *
     * SQLite (the test database) has no MODIFY/ENUM — there the column is
     * plain text and only the row update is needed.
     */
    public function up(): void
    {
        if (DB::getDriverName() === 'sqlite') {
            DB::table('donation_requests')
                ->where('status', 'published')
                ->update(['status' => 'pending']);

            return;
        }

        DB::statement("ALTER TABLE donation_requests MODIFY status
            ENUM('published','pending','accepted','picked_up','completed','expired','cancelled','no_show')
            NOT NULL DEFAULT 'published'");

        DB::table('donation_requests')->where('status', 'published')->update(['status' => 'pending']);

        DB::statement("ALTER TABLE donation_requests MODIFY status
            ENUM('pending','accepted','picked_up','completed','expired','cancelled','no_show')
            NOT NULL DEFAULT 'pending'");
    }

    public function down(): void
    {
        if (DB::getDriverName() === 'sqlite') {
            DB::table('donation_requests')
                ->where('status', 'pending')
                ->update(['status' => 'published']);

            return;
        }

        DB::statement("ALTER TABLE donation_requests MODIFY status
            ENUM('published','pending','accepted','picked_up','completed','expired','cancelled','no_show')
            NOT NULL DEFAULT 'pending'");

        DB::table('donation_requests')->where('status', 'pending')->update(['status' => 'published']);

        DB::statement("ALTER TABLE donation_requests MODIFY status
            ENUM('published','accepted','picked_up','completed','expired','cancelled','no_show')
            NOT NULL DEFAULT 'published'");
    }
};
