<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * One FCM registration token per account — the current device's push
     * mailbox. A fresh login/token-refresh always overwrites it, and logout
     * clears it, so a signed-out device stops receiving that account's pushes.
     */
    public function up(): void
    {
        Schema::table('donors', function (Blueprint $table) {
            $table->string('fcm_token', 255)->nullable()->after('avatar_path');
        });

        Schema::table('charities', function (Blueprint $table) {
            $table->string('fcm_token', 255)->nullable()->after('logo_path');
        });
    }

    public function down(): void
    {
        Schema::table('donors', function (Blueprint $table) {
            $table->dropColumn('fcm_token');
        });

        Schema::table('charities', function (Blueprint $table) {
            $table->dropColumn('fcm_token');
        });
    }
};
