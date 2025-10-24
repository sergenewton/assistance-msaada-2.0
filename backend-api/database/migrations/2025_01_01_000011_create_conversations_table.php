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
        Schema::create('conversations', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('report_id');
            $table->uuid('aps_id')->comment('Agent de Protection Sociale');
            $table->uuid('survivor_id')->comment('Survivante');
            $table->boolean('is_encrypted')->default(true);
            $table->string('encryption_key_id')->nullable()->comment('Reference to encryption key');
            $table->timestamp('last_message_at')->nullable();
            $table->timestamps();

            // Clés étrangères
            $table->foreign('report_id')->references('id')->on('reports')->onDelete('cascade');
            $table->foreign('aps_id')->references('id')->on('users');
            $table->foreign('survivor_id')->references('id')->on('users');

            // Index
            $table->index('report_id');
            $table->index('aps_id');
            $table->index('survivor_id');
            $table->index('last_message_at');
            $table->index(['aps_id', 'last_message_at']);
            $table->index(['survivor_id', 'last_message_at']);

            // Contrainte unique pour éviter les conversations en double
            $table->unique(['report_id', 'aps_id', 'survivor_id'], 'unique_conversation');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('conversations');
    }
};