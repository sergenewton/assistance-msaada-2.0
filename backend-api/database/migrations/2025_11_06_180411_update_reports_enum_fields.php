<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 🧩 Met à jour les types ENUM selon la nouvelle définition

        DB::statement("
            ALTER TABLE reports 
            MODIFY violence_type ENUM(
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
            ) NOT NULL
        ");

        DB::statement("
            ALTER TABLE reports 
            MODIFY victim_age_range ENUM(
                '0-5',
                '6-12',
                '13-17',
                '18-25',
                '26-35',
                '36-50',
                '51+',
                'unknown'
            ) NULL
        ");

        DB::statement("
            ALTER TABLE reports 
            MODIFY victim_gender ENUM(
                'female',
                'male'
            ) NULL
        ");

        DB::statement("
            ALTER TABLE reports 
            MODIFY perpetrator_relationship ENUM(
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
            ) NULL
        ");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // 🔁 Restaure les anciennes définitions si besoin de rollback
        DB::statement("
            ALTER TABLE reports 
            MODIFY violence_type ENUM(
                'physical',
                'sexual',
                'psychological',
                'economic',
                'stalking',
                'forced_marriage',
                'honor_violence',
                'female_genital_mutilation',
                'trafficking',
                'other'
            ) NOT NULL
        ");

        DB::statement("
            ALTER TABLE reports 
            MODIFY victim_age_range ENUM(
                'minor_0_5',
                'minor_6_12',
                'minor_13_17',
                'adult_18_25',
                'adult_26_35',
                'adult_36_50',
                'adult_51_plus',
                'unknown'
            ) NULL
        ");

        DB::statement("
            ALTER TABLE reports 
            MODIFY victim_gender ENUM(
                'female',
                'male',
                'non_binary',
                'prefer_not_say',
                'unknown'
            ) NULL
        ");

        DB::statement("
            ALTER TABLE reports 
            MODIFY perpetrator_relationship ENUM(
                'intimate_partner',
                'ex_partner',
                'family_member',
                'acquaintance',
                'stranger',
                'authority_figure',
                'employer',
                'other',
                'unknown'
            ) NULL
        ");
    }
};
