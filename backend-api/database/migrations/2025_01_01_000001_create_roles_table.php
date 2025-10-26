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
        Schema::create('roles', function (Blueprint $table) {
            $table->id();
            $table->enum('name', ['survivante', 'aps', 'operateur', 'organisation', 'superviseur', 'admin'])
                  ->unique();
            $table->string('display_name');
            $table->text('description')->nullable();
            $table->json('permissions')->nullable(); // Permissions granulaires RBAC
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            // Index
            $table->index('name');
            $table->index('is_active');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('roles');
    }
};