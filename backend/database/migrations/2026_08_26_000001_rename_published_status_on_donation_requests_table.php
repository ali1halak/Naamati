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
     */
    public function up(): void
    {
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
        DB::statement("ALTER TABLE donation_requests MODIFY status
            ENUM('published','pending','accepted','picked_up','completed','expired','cancelled','no_show')
            NOT NULL DEFAULT 'pending'");

        DB::table('donation_requests')->where('status', 'pending')->update(['status' => 'published']);

        DB::statement("ALTER TABLE donation_requests MODIFY status
            ENUM('published','accepted','picked_up','completed','expired','cancelled','no_show')
            NOT NULL DEFAULT 'published'");
    }
};
