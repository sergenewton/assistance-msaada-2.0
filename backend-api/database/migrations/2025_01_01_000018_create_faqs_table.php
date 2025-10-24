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
        Schema::create('faqs', function (Blueprint $table) {
            $table->id();
            $table->json('question')->comment('Multilingual question object');
            $table->json('answer')->comment('Multilingual answer object');
            $table->enum('category', [
                'general', 'reporting', 'safety', 'legal', 'services',
                'privacy', 'emergency', 'children', 'support'
            ]);
            $table->unsignedInteger('order_index')->default(0);
            $table->boolean('is_published')->default(false);
            $table->timestamps();

            // Index
            $table->index('category');
            $table->index('order_index');
            $table->index('is_published');
            $table->index(['category', 'order_index']);
            $table->index(['is_published', 'order_index']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('faqs');
    }
};