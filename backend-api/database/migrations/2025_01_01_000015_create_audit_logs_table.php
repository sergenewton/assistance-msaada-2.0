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
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->uuid('user_id')->nullable()->comment('Null for system actions');
            $table->string('action')->comment('Action performed: viewed_case, exported_data, etc.');
            $table->string('resource_type', 100)->comment('Model type: Report, User, etc.');
            $table->uuid('resource_id')->comment('ID of the affected resource');
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->json('changes')->nullable()->comment('old_values and new_values');
            $table->enum('severity', ['info', 'warning', 'critical'])->default('info');
            $table->timestamp('created_at')->useCurrent();

            // Clé étrangère
            $table->foreign('user_id')->references('id')->on('users')->onDelete('set null');

            // Index pour les performances et la recherche d'audit
            $table->index('user_id');
            $table->index('action');
            $table->index('created_at');
            $table->index(['resource_type', 'resource_id'], 'idx_resource');
            $table->index('severity');
            $table->index(['user_id', 'created_at']);
            $table->index(['action', 'created_at']);
            $table->index(['resource_type', 'created_at']);
            $table->index(['severity', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
    }
};