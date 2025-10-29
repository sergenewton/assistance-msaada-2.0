<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class InitialSetupSeeder extends Seeder
{
    /**
     * Seeder pour la configuration initiale minimale du système.
     * Crée uniquement les rôles de base et le compte super admin.
     */
    public function run(): void
    {
        $this->command->info('🚀 Configuration initiale d\'ASSISTANCE MSAADA 2.0');
        
        // 1. Créer les rôles de base
        $this->createBasicRoles();
        
        // 2. Créer le compte super admin
        $this->createSuperAdmin();
        
        $this->command->info('🎉 Configuration initiale terminée !');
        $this->command->info('📧 Email Super Admin: admin@msaada.cd');
        $this->command->info('🔑 Mot de passe: Admin@2025!');
        $this->command->warn('⚠️  IMPORTANT: Changez ce mot de passe dès la première connexion');
    }

    private function createBasicRoles()
    {
        $this->command->info('📋 Création des rôles de base...');
        
        $roles = [
            ['name' => 'survivante', 'display_name' => 'Survivante / Témoin'],
            ['name' => 'aps', 'display_name' => 'Agent Psychosocial (APS)'],
            ['name' => 'operateur', 'display_name' => 'Opérateur Centre d\'Écoute'],
            ['name' => 'organisation', 'display_name' => 'Organisation Partenaire'],
            ['name' => 'superviseur', 'display_name' => 'Superviseur / Coordinateur'],
            ['name' => 'admin', 'display_name' => 'Administrateur Système'],
        ];

        foreach ($roles as $role) {
            DB::table('roles')->updateOrInsert(
                ['name' => $role['name']],
                [
                    'name' => $role['name'],
                    'display_name' => $role['display_name'],
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );
        }
        
        $this->command->info('✅ Rôles créés avec succès');
    }

    private function createSuperAdmin()
    {
        $this->command->info('👤 Création du compte Super Admin...');
        
        // Récupérer le rôle admin
        $adminRole = DB::table('roles')->where('name', 'admin')->first();
        
        if (!$adminRole) {
            $this->command->error('❌ Rôle admin non trouvé');
            return;
        }

        // Vérifier si un super admin existe déjà
        $existingAdmin = DB::table('users')
            ->where('role_id', $adminRole->id)
            ->first();

        if ($existingAdmin) {
            $this->command->info('ℹ️  Un compte super admin existe déjà');
            return;
        }

        // Créer le compte super admin
        $adminId = Str::uuid();
        
        DB::table('users')->insert([
            'id' => $adminId,
            'email' => encrypt('admin@msaada.cd'), // Email chiffré
            'phone' => encrypt('+243000000000'), // Téléphone chiffré  
            'password' => Hash::make('Admin@2025!'), // Mot de passe fort
            'role_id' => $adminRole->id,
            'organization_id' => null,
            'two_factor_enabled' => false,
            'two_factor_secret' => null,
            'last_login_at' => null,
            'last_login_ip' => null,
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now(),
            'deleted_at' => null,
        ]);

        $this->command->info('✅ Super Admin créé avec succès !');
    }
}