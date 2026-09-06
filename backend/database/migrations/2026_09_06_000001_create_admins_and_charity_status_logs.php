<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Real admin accounts, replacing the shared static header.
 *
 * The old X-Admin-Token had to be embedded in whatever front end called it, so
 * anyone who opened DevTools became an admin, every admin was the same person
 * in the logs, and revoking access meant rotating a secret for everybody.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('admins', function (Blueprint $table) {
            $table->id();
            $table->string('name', 120);
            $table->string('email', 150)->unique();
            $table->string('password', 255);
            $table->timestamps();
        });

        // Who did what to which charity. Mirrors request_status_logs so both
        // audit trails read the same way.
        Schema::create('charity_status_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('charity_id')->constrained('charities')->cascadeOnDelete();

            // Kept when the admin account is deleted: an audit row that loses
            // its actor is still better than one that disappears.
            $table->foreignId('admin_id')->nullable()->constrained('admins')->nullOnDelete();

            $table->string('from_status', 20)->nullable();
            $table->string('to_status', 20);
            $table->string('note', 255)->nullable();
            $table->timestamp('created_at')->useCurrent();

            $table->index(['charity_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('charity_status_logs');
        Schema::dropIfExists('admins');
    }
};
