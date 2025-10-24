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
        Schema::create('referrals', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('report_id');
            $table->uuid('organization_id');
            $table->uuid('referred_by');
            
            $table->enum('service_type', [
                'psychological_support', 'medical_care', 'legal_aid', 
                'shelter', 'economic_empowerment', 'police_protection',
                'child_protection', 'emergency_transport'
            ]);
            
            $table->enum('priority', ['low', 'medium', 'high', 'urgent']);
            $table->enum('status', ['pending', 'accepted', 'declined', 'completed'])->default('pending');
            
            $table->timestamp('response_deadline');
            $table->timestamp('accepted_at')->nullable();
            $table->uuid('accepted_by')->nullable();
            $table->timestamp('declined_at')->nullable();
            $table->text('decline_reason')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->text('notes')->nullable();
            
            $table->timestamps();

            // Clés étrangères
            $table->foreign('report_id')->references('id')->on('reports')->onDelete('cascade');
            $table->foreign('organization_id')->references('id')->on('organizations');
            $table->foreign('referred_by')->references('id')->on('users');
            $table->foreign('accepted_by')->references('id')->on('users')->onDelete('set null');

            // Index pour les performances
            $table->index('report_id');
            $table->index('organization_id');
            $table->index('status');
            $table->index('priority');
            $table->index('response_deadline');
            $table->index('service_type');
            $table->index(['status', 'priority']);
            $table->index(['organization_id', 'status']);
            $table->index(['report_id', 'status']);
            $table->index(['response_deadline', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('referrals');
    }
};