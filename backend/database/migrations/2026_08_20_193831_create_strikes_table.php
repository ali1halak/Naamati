<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('strikes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('charity_id')->constrained('charities')->cascadeOnDelete();
            $table->foreignId('donation_request_id')->nullable()->constrained('donation_requests')->nullOnDelete();
            $table->enum('reason', ['no_show'])->default('no_show');
            $table->string('note', 255)->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('strikes');
    }
};