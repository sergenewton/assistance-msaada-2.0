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
        Schema::create('messages', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('conversation_id');
            $table->uuid('sender_id');
            $table->enum('message_type', ['text', 'audio', 'image', 'location', 'document'])->default('text');
            $table->longText('content')->nullable()->comment('Encrypted message content');
            $table->text('file_path')->nullable()->comment('Path to file attachment if applicable');
            $table->boolean('is_read')->default(false);
            $table->timestamp('read_at')->nullable();
            $table->boolean('is_deleted_by_sender')->default(false);
            $table->boolean('is_deleted_by_receiver')->default(false);
            $table->timestamp('auto_delete_at')->nullable()->comment('Automatic deletion timestamp');
            $table->timestamps();

            // Clés étrangères
            $table->foreign('conversation_id')->references('id')->on('conversations')->onDelete('cascade');
            $table->foreign('sender_id')->references('id')->on('users');

            // Index pour les performances
            $table->index('conversation_id');
            $table->index('sender_id');
            $table->index('created_at');
            $table->index('is_read');
            $table->index('auto_delete_at');
            $table->index('message_type');
            $table->index(['conversation_id', 'created_at']);
            $table->index(['conversation_id', 'is_read']);
            $table->index(['auto_delete_at', 'created_at']); // Pour le nettoyage automatique
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('messages');
    }
};