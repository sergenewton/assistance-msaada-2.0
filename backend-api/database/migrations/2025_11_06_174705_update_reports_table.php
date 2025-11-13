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
        Schema::table('reports', function (Blueprint $table) {

            // 🔄 Modifier la colonne violence_type (changement d'énumération)
            $table->enum('violence_type', [
                'rape',
                'sexual_assault',
                'sexual_harassment',
                'sexual_exploitation',
                'forced_marriage',
                'female_genital_mutilation',
                'incest',
                'sextortion',
                'physical_assault',
                'denial_resources',
                'psychological_violence',
                'sexual_slavery',
                'other'
            ])->change();

            // 🔄 Modifier les colonnes de tranches d'âge
            $table->enum('victim_age_range', [
                '0-5', '6-12', '13-17', 
                '18-25', '26-35', '36-50', 
                '51+', 'unknown'
            ])->nullable()->change();

            // 🔄 Réduire le genre aux deux valeurs
            $table->enum('victim_gender', ['female', 'male'])->nullable()->change();

            // 🔄 Modifier la colonne perpetrator_relationship
            $table->enum('perpetrator_relationship', [
                'family_member',
                'employer',
                'colleague',
                'teacher',
                'authority',
                'religious_leader',
                'neighbor',
                'stranger',
                'partner',
                'parent',
                'unknown',
                'other'
            ])->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('reports', function (Blueprint $table) {

            // Rétablir les anciennes versions
            $table->enum('violence_type', [
                'physical', 'sexual', 'psychological', 'economic', 
                'stalking', 'forced_marriage', 'honor_violence', 
                'female_genital_mutilation', 'trafficking', 'other'
            ])->change();

            $table->enum('victim_age_range', [
                'minor_0_5', 'minor_6_12', 'minor_13_17', 
                'adult_18_25', 'adult_26_35', 'adult_36_50', 
                'adult_51_plus', 'unknown'
            ])->nullable()->change();

            $table->enum('victim_gender', ['female', 'male', 'non_binary', 'prefer_not_say', 'unknown'])->nullable()->change();

            $table->enum('perpetrator_relationship', [
                'intimate_partner', 'ex_partner', 'family_member', 
                'acquaintance', 'stranger', 'authority_figure', 
                'employer', 'other', 'unknown'
            ])->nullable()->change();
        });
    }
};
