<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class DashboardTestUsersSeeder extends Seeder
{
    /**
     * Seed des utilisateurs de test pour valider les tableaux de bord
     * Ces utilisateurs ont des emails et mots de passe simples pour les tests
     */
    public function run(): void
    {
        // Récupération des rôles (même méthode que UsersSeeder.php)
        $roles = DB::table('roles')->get()->keyBy('name');
        
        if ($roles->isEmpty()) {
            $this->command->error('❌ Aucun rôle trouvé. Exécutez d\'abord: php artisan db:seed --class=RolesAndPermissionsSeeder');
            return;
        }

        // Utilisateurs de test avec emails et mots de passe simples
        $testUsers = [
            // 1. APS Test User
            [
                'email' => 'aps@msaada.com',
                'phone' => '+243998001001',
                'password' => 'password123',
                'role_id' => $roles['aps']->id,
                'is_active' => true
            ],
            
            // 2. Opérateur Test User  
            [
                'email' => 'operator@msaada.com',
                'phone' => '+243998001002',
                'password' => 'password123',
                'role_id' => $roles['operateur']->id,
                'is_active' => true
            ],
            
            // 3. Organisation Test User
            [
                'email' => 'org@msaada.com',
                'phone' => '+243998001003',
                'password' => 'password123',
                'role_id' => $roles['organisation']->id,
                'is_active' => true
            ],
            
            // 4. Admin Test User
            [
                'email' => 'admin@msaada.com', 
                'phone' => '+243998001004',
                'password' => 'password123',
                'role_id' => $roles['admin']->id,
                'is_active' => true
            ],
            
            // 5. Superviseur Test User
            [
                'email' => 'supervisor@msaada.com',
                'phone' => '+243998001005', 
                'password' => 'password123',
                'role_id' => $roles['superviseur']->id,
                'is_active' => true
            ]
        ];

        $this->command->info('🔄 Création des utilisateurs de test pour les dashboards...');

        // Insertion/mise à jour des utilisateurs de test (même méthode que UsersSeeder.php)
        foreach ($testUsers as $user) {
            // Vérifier si l'utilisateur existe déjà (par email chiffré - c'est complexe avec le chiffrement)
            // Utilisons la méthode d'insertion simple du seeder existant
            DB::table('users')->updateOrInsert(
                ['email' => $user['email'], 'phone' => $user['phone']], // Condition pour vérifier l'existence
                [
                    'id' => \Illuminate\Support\Str::uuid(), // Générer un UUID
                    'email' => $user['email'],
                    'phone' => $user['phone'],
                    'password' => Hash::make($user['password']),
                    'role_id' => $user['role_id'],
                    'is_active' => $user['is_active'],
                    'created_at' => now(),
                    'updated_at' => now()
                ]
            );
            $this->command->info("✅ Utilisateur {$user['email']} créé/mis à jour");
        }
        
        $this->command->info('');
        $this->command->info('🎉 Utilisateurs de test créés avec succès !');
        $this->command->info('');
        $this->command->info('📋 Informations de connexion :');
        $this->command->info('┌─────────────────────────────────────────────────────────┐');
        $this->command->info('│  Email                    │  Mot de passe │  Rôle       │');
        $this->command->info('├─────────────────────────────────────────────────────────┤');
        $this->command->info('│  aps@msaada.com          │  password123  │  APS         │');
        $this->command->info('│  operator@msaada.com     │  password123  │  Opérateur   │');
        $this->command->info('│  org@msaada.com          │  password123  │  Organisation│');
        $this->command->info('│  admin@msaada.com        │  password123  │  Admin       │');
        $this->command->info('│  supervisor@msaada.com   │  password123  │  Superviseur │');
        $this->command->info('└─────────────────────────────────────────────────────────┘');
        $this->command->info('');
        $this->command->info('🚀 Vous pouvez maintenant tester la connexion et la redirection');
        $this->command->info('   vers les différents tableaux de bord !');
    }
}