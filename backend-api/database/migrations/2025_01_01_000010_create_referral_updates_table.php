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
        Schema::create('referral_updates', function (Blueprint $table) {
            $table->id();
            $table->uuid('referral_id');
            $table->uuid('updated_by');
            $table->enum('status', ['pending', 'accepted', 'declined', 'completed']);
            $table->text('comment')->nullable();
            $table->json('documents')->nullable()->comment('Array of document references');
            $table->timestamp('created_at')->useCurrent();

            // Clés étrangères
            $table->foreign('referral_id')->references('id')->on('referrals')->onDelete('cascade');
            $table->foreign('updated_by')->references('id')->on('users');

            // Index
            $table->index('referral_id');
            $table->index('updated_by');
            $table->index('created_at');
            $table->index(['referral_id', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('referral_updates');
    }
};