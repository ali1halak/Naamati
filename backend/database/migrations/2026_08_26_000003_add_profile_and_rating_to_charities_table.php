<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * The donor sees the assigned charity's card on the "accepted" screen:
     * logo, average stars and how many donations it has received.
     *
     * The average is denormalised here rather than averaged on every read —
     * it is shown on a screen the donor polls while waiting, and it only
     * changes when a rating is written. RatingObserver keeps it in sync.
     */
    public function up(): void
    {
        Schema::table('charities', function (Blueprint $table) {
            $table->string('logo_path', 255)->nullable()->after('license_document');
            $table->decimal('rating_avg', 3, 2)->nullable()->after('logo_path');
            $table->unsignedInteger('ratings_count')->default(0)->after('rating_avg');
        });
    }

    public function down(): void
    {
        Schema::table('charities', function (Blueprint $table) {
            $table->dropColumn(['logo_path', 'rating_avg', 'ratings_count']);
        });
    }
};
