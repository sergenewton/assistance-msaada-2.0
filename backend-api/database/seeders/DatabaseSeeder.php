<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->command->info('🚀 Démarrage du seeding pour ASSISTANCE MSAADA 2.0');
        
        // Seeding des rôles et permissions selon les 6 profils définis
        $this->call(RolesAndPermissionsSeeder::class);
        
        // Création automatique du compte Super Admin
        $this->call(SuperAdminSeeder::class);
        
        // Seeding des organisations partenaires
        $this->call(OrganizationsSeeder::class);
        
        // Seeding des utilisateurs de test pour chaque profil
        $this->call(UsersSeeder::class);
        
        $this->command->info('🎉 Seeding terminé avec succès !');
        $this->command->info('📊 Profils créés:');
        $this->command->info('   1. Survivante / Témoin - Accès mobile');
        $this->command->info('   2. Agent Psychosocial (APS) - Accès web + mobile');
        $this->command->info('   3. Opérateur Centre d\'Écoute - Accès web');
        $this->command->info('   4. Organisation Partenaire - Accès web (portail)');
        $this->command->info('   5. Administrateur Système - Accès web (admin)');
        $this->command->info('   6. Superviseur / Coordinateur - Accès web (vue globale)');
    }
}