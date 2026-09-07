<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Mirrors `charities.logo_path` — lets a donor set a profile photo the
     * same way a charity sets its logo.
     */
    public function up(): void
    {
        Schema::table('donors', function (Blueprint $table) {
            $table->string('avatar_path', 255)->nullable()->after('phone');
        });
    }

    public function down(): void
    {
        Schema::table('donors', function (Blueprint $table) {
            $table->dropColumn('avatar_path');
        });
    }
};
