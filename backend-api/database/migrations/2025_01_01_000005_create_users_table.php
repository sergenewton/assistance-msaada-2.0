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
        Schema::create('users', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->text('email')->comment('Encrypted email');
            $table->text('phone')->comment('Encrypted phone');
            $table->string('password');
            $table->unsignedBigInteger('role_id');
            $table->uuid('organization_id')->nullable();
            $table->boolean('two_factor_enabled')->default(false);
            $table->text('two_factor_secret')->nullable()->comment('Encrypted 2FA secret');
            $table->timestamp('last_login_at')->nullable();
            $table->string('last_login_ip', 45)->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();

            // Clés étrangères
            $table->foreign('role_id')->references('id')->on('roles');
            $table->foreign('organization_id')->references('id')->on('organizations')->onDelete('set null');

            // Index pour les performances
            $table->index('role_id');
            $table->index('organization_id');
            $table->index('is_active');
            $table->index('last_login_at');
            $table->index(['role_id', 'is_active']);
            $table->index(['organization_id', 'is_active']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};