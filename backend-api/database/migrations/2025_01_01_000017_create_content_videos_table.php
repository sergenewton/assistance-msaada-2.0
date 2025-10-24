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
        Schema::create('content_videos', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->json('title')->comment('Multilingual title object');
            $table->json('description')->nullable()->comment('Multilingual description object');
            $table->string('video_url', 500);
            $table->string('thumbnail_url', 500)->nullable();
            $table->unsignedInteger('duration')->nullable()->comment('Duration in seconds');
            $table->enum('category', [
                'prevention', 'rights_awareness', 'support_services', 
                'legal_information', 'health_safety', 'empowerment',
                'child_protection', 'emergency_procedures'
            ]);
            $table->unsignedInteger('views_count')->default(0);
            $table->boolean('is_published')->default(false);
            $table->timestamps();

            // Index
            $table->index('category');
            $table->index('is_published');
            $table->index('views_count');
            $table->index('duration');
            $table->index(['category', 'is_published']);
            $table->index(['is_published', 'views_count']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('content_videos');
    }
};