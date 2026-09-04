<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('charity_violations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('charity_id')->constrained()->cascadeOnDelete();
            $table->foreignId('order_id')->nullable()
                ->constrained('donation_orders')->nullOnDelete();
            $table->enum('reason', ['delay', 'storage', 'hygiene']);
            $table->enum('severity', ['low', 'medium', 'high'])->default('medium');
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('charity_violations');
    }
};
