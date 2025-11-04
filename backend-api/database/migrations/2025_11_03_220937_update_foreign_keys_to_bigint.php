<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $tables = ['users', 'referrals', 'reports']; // adapte si tu as d'autres tables liées

        foreach ($tables as $table) {
            if (Schema::hasTable($table) && Schema::hasColumn($table, 'organization_id')) {
                try {
                    // 🔹 Supprimer la contrainte FK si elle existe
                    DB::statement("ALTER TABLE `$table` DROP FOREIGN KEY `{$table}_organization_id_foreign`;");
                } catch (\Throwable $e) {
                    // Ignore si la FK n'existe pas
                }

                Schema::table($table, function (Blueprint $table) {
                    // 🔹 Changer le type vers BIGINT UNSIGNED
                    $table->unsignedBigInteger('organization_id')->nullable()->change();
                });

                try {
                    // 🔹 Recréer la contrainte
                    DB::statement("
                        ALTER TABLE `$table`
                        ADD CONSTRAINT `{$table}_organization_id_foreign`
                        FOREIGN KEY (organization_id)
                        REFERENCES organizations(id)
                        ON DELETE CASCADE;
                    ");
                } catch (\Throwable $e) {
                    // Ignore les doublons ou erreurs mineures
                }
            }
        }
    }

    public function down(): void
    {
        $tables = ['users', 'referrals', 'reports'];
        foreach ($tables as $table) {
            if (Schema::hasTable($table) && Schema::hasColumn($table, 'organization_id')) {
                try {
                    DB::statement("ALTER TABLE `$table` DROP FOREIGN KEY `{$table}_organization_id_foreign`;");
                } catch (\Throwable $e) {
                    //
                }

                Schema::table($table, function (Blueprint $table) {
                    $table->char('organization_id', 36)->nullable()->change();
                });
            }
        }
    }
};
