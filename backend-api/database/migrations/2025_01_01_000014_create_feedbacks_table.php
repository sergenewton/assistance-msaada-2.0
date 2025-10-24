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
        Schema::create('feedbacks', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('report_id');
            $table->enum('feedback_type', ['first_contact', 'referral', 'closure', 'follow_up']);
            $table->unsignedTinyInteger('rating')->nullable()->comment('Rating from 1 to 5');
            $table->json('questions_answers')->nullable()->comment('Structured Q&A responses');
            $table->text('comment')->nullable();
            $table->timestamp('submitted_at')->useCurrent();
            $table->timestamps();

            // Clé étrangère
            $table->foreign('report_id')->references('id')->on('reports')->onDelete('cascade');

            // Index
            $table->index('report_id');
            $table->index('feedback_type');
            $table->index('rating');
            $table->index('submitted_at');
            $table->index(['report_id', 'feedback_type']);
            
            // Check constraint pour le rating
            $table->check('rating IS NULL OR (rating >= 1 AND rating <= 5)');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('feedbacks');
    }
};