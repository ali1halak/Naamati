<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Free-text category name for donations filed under the "غير ذلك" (Other)
 * category — without it the record would just say "غير ذلك" and mean nothing
 * to the charity reading the list.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('donation_requests', function (Blueprint $table) {
            $table->string('custom_category', 150)
                ->nullable()
                ->after('description');
        });
    }

    public function down(): void
    {
        Schema::table('donation_requests', function (Blueprint $table) {
            $table->dropColumn('custom_category');
        });
    }
};
