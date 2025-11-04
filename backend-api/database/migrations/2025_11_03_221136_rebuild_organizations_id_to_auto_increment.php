<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // ⚙️ 1. Désactiver les clés étrangères temporairement
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');

        // ⚙️ 2. Créer une nouvelle table temporaire avec le bon schéma
        Schema::create('organizations_tmp', function (Blueprint $table) {
            $table->id(); // auto_increment BIGINT UNSIGNED PRIMARY KEY
            $table->string('name')->nullable();
            $table->string('type', 50)->nullable();
            $table->json('specialties')->nullable();
            $table->string('contact_email')->nullable();
            $table->string('contact_phone')->nullable();
            $table->text('address')->nullable();
            $table->string('province')->nullable();
            $table->string('commune')->nullable();
            $table->boolean('is_active')->default(true);
            $table->integer('max_capacity')->unsigned()->nullable();
            $table->integer('current_load')->unsigned()->nullable();
            $table->json('languages_spoken')->nullable();
            $table->decimal('performance_score', 3, 1)->nullable();
            $table->timestamps();
            $table->softDeletes();
        });

        // ⚙️ 3. Copier les données depuis l’ancienne table
        DB::statement('INSERT INTO organizations_tmp (name, type, specialties, contact_email, contact_phone, address, province, commune, is_active, max_capacity, current_load, languages_spoken, performance_score, created_at, updated_at, deleted_at)
                       SELECT name, type, specialties, contact_email, contact_phone, address, province, commune, is_active, max_capacity, current_load, languages_spoken, performance_score, created_at, updated_at, deleted_at
                       FROM organizations;');

        // ⚙️ 4. Supprimer l’ancienne table
        Schema::dropIfExists('organizations');

        // ⚙️ 5. Renommer la nouvelle table
        Schema::rename('organizations_tmp', 'organizations');

        // ⚙️ 6. Réactiver les FK
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');
    }

    public function down(): void
    {
        // Tu peux ici remettre un id CHAR(36) si besoin
    }
};
