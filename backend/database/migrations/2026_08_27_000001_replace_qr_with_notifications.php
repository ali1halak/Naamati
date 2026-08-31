<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * The QR handover check is dropped: the donor now confirms the handover with a
 * plain action, and every confirmation is recorded as a notification the admin
 * can read.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('donation_requests', function (Blueprint $table) {
            $table->dropUnique(['qr_token']);
            $table->dropColumn('qr_token');
        });

        Schema::create('notifications', function (Blueprint $table) {
            $table->id();

            // Recipients live in different tables (and the admin has no table at
            // all), so the target is stored as a type + optional id rather than
            // a foreign key. recipient_id is null for admin notifications.
            $table->enum('recipient_type', ['admin', 'donor', 'charity']);
            $table->unsignedBigInteger('recipient_id')->nullable();

            $table->string('type', 50);
            $table->json('payload')->nullable();
            $table->boolean('is_read')->default(false);
            $table->foreignId('donation_request_id')->nullable()
                ->constrained('donation_requests')->nullOnDelete();
            $table->timestamps();

            $table->index(['recipient_type', 'recipient_id', 'is_read']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications');

        Schema::table('donation_requests', function (Blueprint $table) {
            $table->string('qr_token', 64)->nullable()->unique();
        });
    }
};
