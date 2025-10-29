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
        Schema::create('reports', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('report_number', 50)->unique()->comment('Format: VBG-YYYY-XXXXX');
            $table->uuid('reporter_id')->nullable()->comment('Null if anonymous');
            $table->boolean('is_anonymous')->default(false);
            
            // Types de violence
            $table->enum('violence_type', [
                'physical', 'sexual', 'psychological', 'economic', 
                'stalking', 'forced_marriage', 'honor_violence', 
                'female_genital_mutilation', 'trafficking', 'other'
            ]);
            
            // Niveau d'urgence
            $table->enum('urgency_level', ['low', 'moderate', 'high', 'critical']);
            $table->unsignedTinyInteger('urgency_score')->default(0)->comment('0-100 score');
            
            // Informations victime
            $table->enum('victim_age_range', [
                'minor_0_5', 'minor_6_12', 'minor_13_17', 
                'adult_18_25', 'adult_26_35', 'adult_36_50', 
                'adult_51_plus', 'unknown'
            ])->nullable();
            $table->enum('victim_gender', ['female', 'male', 'non_binary', 'prefer_not_say', 'unknown'])->nullable();
            $table->enum('victim_status', ['single', 'married', 'divorced', 'widow', 'separated', 'unknown'])->nullable();
            
            // Détails incident
            $table->date('incident_date')->nullable();
            $table->text('incident_location')->nullable();
            $table->enum('incident_frequency', ['first_time', 'repeated', 'chronic'])->nullable();
            $table->longText('narrative')->nullable()->comment('Encrypted narrative');
            
            // Auteur des violences
            $table->enum('perpetrator_relationship', [
                'intimate_partner', 'ex_partner', 'family_member', 
                'acquaintance', 'stranger', 'authority_figure', 
                'employer', 'other', 'unknown'
            ])->nullable();
            
            // Évaluation des risques
            $table->boolean('is_safe_now')->nullable();
            $table->boolean('needs_urgent_medical')->default(false);
            $table->boolean('children_at_risk')->default(false);
            $table->boolean('death_threats')->default(false);
            
            // Localisation
            $table->string('location_province')->nullable();
            $table->string('location_commune')->nullable();
            $table->string('location_quartier')->nullable();
            
            // Préférences de contact
            $table->enum('preferred_contact_method', ['sms', 'call', 'whatsapp', 'in_app', 'none'])->nullable();
            $table->json('preferred_contact_hours')->nullable()->comment('Array of preferred hours');
            $table->text('safety_code_word')->nullable()->comment('Encrypted safety word');
            
            // Gestion du cas
            $table->enum('status', ['new', 'triaged', 'aps_assigned', 'referred', 'in_progress', 'closed'])->default('new');
            $table->uuid('assigned_aps_id')->nullable();
            $table->timestamp('assigned_at')->nullable();
            $table->timestamp('closed_at')->nullable();
            $table->text('closure_reason')->nullable();
            
            $table->timestamps();
            $table->softDeletes();

            // Clés étrangères
            $table->foreign('reporter_id')->references('id')->on('users')->onDelete('set null');
            $table->foreign('assigned_aps_id')->references('id')->on('users')->onDelete('set null');

            // Index pour les performances
            $table->index('status');
            $table->index('urgency_level');
            $table->index('violence_type');
            $table->index('reporter_id');
            $table->index('assigned_aps_id');
            $table->index('created_at');
            $table->index('urgency_score');
            $table->index('location_province');
            $table->index(['status', 'urgency_level']);
            $table->index(['assigned_aps_id', 'status']);
            $table->index(['violence_type', 'created_at']);
            
            // Note: Check constraints will be added via raw SQL if needed
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reports');
    }
};