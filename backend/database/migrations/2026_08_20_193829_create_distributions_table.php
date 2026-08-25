<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('distributions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('donation_request_id')->unique()->constrained('donation_requests')->cascadeOnDelete();
            $table->unsignedInteger('families_count');
            $table->unsignedInteger('individuals_count');
            $table->string('area', 100);
            $table->dateTime('distributed_at');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('distributions');
    }
};