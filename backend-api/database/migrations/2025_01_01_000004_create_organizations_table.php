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
        Schema::create('organizations', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name');
            $table->enum('type', ['ngo', 'hospital', 'police', 'legal', 'shelter', 'economic']);
            $table->json('specialties')->nullable()->comment('Array of specialties like ["minors", "sexual_violence"]');
            $table->string('contact_email')->nullable();
            $table->string('contact_phone')->nullable();
            $table->text('address')->nullable();
            $table->string('province')->nullable();
            $table->string('commune')->nullable();
            $table->boolean('is_active')->default(true);
            $table->unsignedInteger('max_capacity')->nullable();
            $table->unsignedInteger('current_load')->default(0);
            $table->json('languages_spoken')->nullable()->comment('Array of language codes');
            $table->decimal('performance_score', 3, 2)->default(0.00);
            $table->timestamps();
            $table->softDeletes();

            // Index pour les performances
            $table->index('type');
            $table->index('province');
            $table->index('is_active');
            $table->index('performance_score');
            $table->index(['type', 'province']);
            $table->index(['is_active', 'current_load']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('organizations');
    }
};