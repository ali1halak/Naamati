<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('donation_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('donor_id')->constrained('donors')->cascadeOnDelete();
            $table->foreignId('charity_id')->nullable()->constrained('charities')->nullOnDelete();
            $table->foreignId('food_category_id')->constrained('food_categories')->restrictOnDelete();
            $table->boolean('needs_cooking')->default(false);
            $table->string('description', 255)->nullable();
            $table->dateTime('valid_until');
            $table->dateTime('pickup_until');
            $table->string('pickup_address', 255);
            $table->string('contact_phone', 20);
            $table->enum('status', ['published', 'accepted', 'picked_up', 'completed', 'expired', 'cancelled', 'no_show'])
                  ->default('published');
            $table->string('qr_token', 64)->nullable()->unique();
            $table->timestamp('accepted_at')->nullable();
            $table->timestamp('picked_up_at')->nullable();
            $table->timestamp('confirmed_at')->nullable();
            $table->timestamps();

            $table->index('status');
            $table->index(['status', 'valid_until']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('donation_requests');
    }
};