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
        Schema::create('report_needs', function (Blueprint $table) {
            $table->id();
            $table->uuid('report_id');
            $table->enum('need_type', ['psychological', 'medical', 'legal', 'shelter', 'economic', 'police']);
            $table->unsignedTinyInteger('priority')->default(1)->comment('1-5 priority level');
            $table->boolean('is_fulfilled')->default(false);
            $table->timestamps();

            // Clé étrangère
            $table->foreign('report_id')->references('id')->on('reports')->onDelete('cascade');

            // Index
            $table->index('report_id');
            $table->index('need_type');
            $table->index('priority');
            $table->index(['report_id', 'need_type']);
            $table->index(['is_fulfilled', 'priority']);

            // Contrainte unique pour éviter les doublons
            $table->unique(['report_id', 'need_type']);
            
            // Check constraint
            $table->check('priority >= 1 AND priority <= 5');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('report_needs');
    }
};