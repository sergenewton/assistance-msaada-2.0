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
        Schema::create('content_articles', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->enum('category', [
                'prevention', 'rights_awareness', 'support_services', 
                'legal_information', 'health_safety', 'empowerment',
                'child_protection', 'emergency_procedures'
            ]);
            $table->json('title')->comment('Multilingual title object');
            $table->string('slug')->unique();
            $table->json('content')->comment('Multilingual content object');
            $table->string('image_url', 500)->nullable();
            $table->uuid('author_id');
            $table->unsignedInteger('views_count')->default(0);
            $table->boolean('is_published')->default(false);
            $table->timestamp('published_at')->nullable();
            $table->timestamps();

            // Clé étrangère
            $table->foreign('author_id')->references('id')->on('users');

            // Index
            $table->index('category');
            $table->index('is_published');
            $table->index('slug');
            $table->index('author_id');
            $table->index('published_at');
            $table->index('views_count');
            $table->index(['category', 'is_published']);
            $table->index(['is_published', 'published_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('content_articles');
    }
};