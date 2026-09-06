<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Two-sided handover confirmation, and photos of the food.
 *
 * The handover used to move on the donor's word alone. Now both parties press
 * their own button and the request only reaches `picked_up` once the two
 * timestamps are set — neither side can claim a pickup that never happened
 * without the other agreeing.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('donation_requests', function (Blueprint $table) {
            // confirmed_at only ever mirrored picked_up_at; it becomes the
            // donor's half of the handover.
            $table->renameColumn('confirmed_at', 'donor_confirmed_at');
        });

        Schema::table('donation_requests', function (Blueprint $table) {
            $table->timestamp('charity_confirmed_at')->nullable()->after('donor_confirmed_at');
        });

        // Several photos per request: the donor shoots the trays, the charity
        // sees what it is coming for before it drives out.
        Schema::create('donation_request_images', function (Blueprint $table) {
            $table->id();
            $table->foreignId('donation_request_id')->constrained('donation_requests')->cascadeOnDelete();
            $table->string('path', 255);
            $table->unsignedTinyInteger('sort_order')->default(0);
            $table->timestamps();

            $table->index(['donation_request_id', 'sort_order']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('donation_request_images');

        Schema::table('donation_requests', function (Blueprint $table) {
            $table->dropColumn('charity_confirmed_at');
        });

        Schema::table('donation_requests', function (Blueprint $table) {
            $table->renameColumn('donor_confirmed_at', 'confirmed_at');
        });
    }
};
