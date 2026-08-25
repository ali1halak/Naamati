<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('charities', function (Blueprint $table) {
            $table->id();
            $table->string('name', 120);
            $table->string('email', 150)->unique();
            $table->string('phone', 20);
            $table->string('password', 255);
            $table->boolean('has_kitchen')->default(false);
            $table->enum('status', ['pending', 'active', 'suspended'])->default('pending');
            $table->string('license_document', 255)->nullable();
            $table->string('address', 255);
            $table->time('work_start');
            $table->time('work_end');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('charities');
    }
};