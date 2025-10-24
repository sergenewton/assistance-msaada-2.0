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
        Schema::create('notifications', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('user_id');
            $table->enum('type', ['new_case', 'assignment', 'update', 'reminder', 'alert', 'referral_response']);
            $table->string('title');
            $table->text('body');
            $table->json('data')->nullable()->comment('Additional contextual data');
            $table->json('channels_sent')->nullable()->comment('Array of channels: sms, email, push, whatsapp');
            $table->boolean('is_read')->default(false);
            $table->timestamp('read_at')->nullable();
            $table->timestamps();

            // Clé étrangère
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');

            // Index pour les performances
            $table->index('user_id');
            $table->index('is_read');
            $table->index('created_at');
            $table->index('type');
            $table->index(['user_id', 'is_read']);
            $table->index(['user_id', 'created_at']);
            $table->index(['type', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};