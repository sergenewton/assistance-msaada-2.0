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
        Schema::create('report_files', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('report_id');
            $table->enum('file_type', ['photo', 'audio', 'document', 'video']);
            $table->text('file_path')->comment('Encrypted file path for secure storage');
            $table->text('file_name')->comment('Encrypted original filename');
            $table->unsignedBigInteger('file_size')->comment('File size in bytes');
            $table->string('mime_type');
            $table->uuid('uploaded_by');
            $table->timestamps();

            // Clés étrangères
            $table->foreign('report_id')->references('id')->on('reports')->onDelete('cascade');
            $table->foreign('uploaded_by')->references('id')->on('users');

            // Index
            $table->index('report_id');
            $table->index('file_type');
            $table->index('uploaded_by');
            $table->index('created_at');
            $table->index(['report_id', 'file_type']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('report_files');
    }
};