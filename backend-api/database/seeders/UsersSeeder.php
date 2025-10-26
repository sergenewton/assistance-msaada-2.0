<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UsersSeeder extends Seeder
{
    /**
     * Seed des utilisateurs de test pour chaque profil
     */
    public function run(): void
    {
        // Récupération des rôles
        $roles = DB::table('roles')->get()->keyBy('name');
        
        // Utilisateurs de test pour chaque profil
        $users = [
            // 1. Survivante / Témoin
            [
                'email' => null, // Pas d'email obligatoire pour les survivantes
                'phone' => '+243901234567',
                'password' => Hash::make('SurvivantSecure123!'),
                'role_id' => $roles['survivante']->id,
                'first_name' => 'Marie',
                'last_name' => 'Anonyme',
                'is_active' => true,
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
                'created_at' => now(),
                'updated_at' => now()
            ],
            
            // 2. Agent Psychosocial (APS)
            [
                'email' => 'aps@msaada.org',
                'phone' => '+243901234568',
                'password' => Hash::make('APSSecure123!'),
                'role_id' => $roles['aps']->id,
                'first_name' => 'Dr. Sarah',
                'last_name' => 'Mukendi',
                'is_active' => true,
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
                'created_at' => now(),
                'updated_at' => now()
            ],
            
            // 3. Opérateur Centre d'Écoute
            [
                'email' => 'operateur@msaada.org',
                'phone' => '+243901234569',
                'password' => Hash::make('OperatorSecure123!'),
                'role_id' => $roles['operateur']->id,
                'first_name' => 'Jean',
                'last_name' => 'Kabongo',
                'is_active' => true,
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
                'created_at' => now(),
                'updated_at' => now()
            ],
            
            // 4. Organisation Partenaire - Hôpital
            [
                'email' => 'hopital@partenaire.org',
                'phone' => '+243901234570',
                'password' => Hash::make('HopitalSecure123!'),
                'role_id' => $roles['organisation']->id,
                'first_name' => 'Dr. Michel',
                'last_name' => 'Tshala',
                'organization_name' => 'Hôpital Général de Kinshasa',
                'organization_type' => 'medical',
                'is_active' => true,
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
                'created_at' => now(),
                'updated_at' => now()
            ],
            
            // 5. Organisation Partenaire - Police
            [
                'email' => 'police@partenaire.org',
                'phone' => '+243901234571',
                'password' => Hash::make('PoliceSecure123!'),
                'role_id' => $roles['organisation']->id,
                'first_name' => 'Commissaire Grace',
                'last_name' => 'Matondo',
                'organization_name' => 'Police Nationale Congolaise - Bureau VBG',
                'organization_type' => 'security',
                'is_active' => true,
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
                'created_at' => now(),
                'updated_at' => now()
            ],
            
            // 6. Organisation Partenaire - ONG Juridique
            [
                'email' => 'juridique@partenaire.org',
                'phone' => '+243901234572',
                'password' => Hash::make('JuridiqueSecure123!'),
                'role_id' => $roles['organisation']->id,
                'first_name' => 'Me. Antoinette',
                'last_name' => 'Nsimba',
                'organization_name' => 'Centre d\'Assistance Juridique aux Femmes',
                'organization_type' => 'legal',
                'is_active' => true,
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
                'created_at' => now(),
                'updated_at' => now()
            ],
            
            // 7. Administrateur Système
            [
                'email' => 'admin@msaada.org',
                'phone' => '+243901234573',
                'password' => Hash::make('AdminSecure123!'),
                'role_id' => $roles['admin']->id,
                'first_name' => 'Kashosi',
                'last_name' => 'Chen',
                'is_active' => true,
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
                'created_at' => now(),
                'updated_at' => now()
            ],
            
            // 8. Superviseur / Coordinateur
            [
                'email' => 'superviseur@msaada.org',
                'phone' => '+243901234574',
                'password' => Hash::make('SupervisorSecure123!'),
                'role_id' => $roles['superviseur']->id,
                'first_name' => 'Directrice Esperance',
                'last_name' => 'Mbuyi',
                'is_active' => true,
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
                'created_at' => now(),
                'updated_at' => now()
            ],
            
            // Utilisateurs supplémentaires pour tests
            // APS supplémentaires
            [
                'email' => 'aps2@msaada.org',
                'phone' => '+243901234575',
                'password' => Hash::make('APS2Secure123!'),
                'role_id' => $roles['aps']->id,
                'first_name' => 'Dr. Patient',
                'last_name' => 'Kitenge',
                'is_active' => true,
                'email_verified_at' => now(),
                'phone_verified_at' => now(),
                'created_at' => now(),
                'updated_at' => now()
            ],
            
            // Survivantes supplémentaires (pour tests du système)
            [
                'email' => null,
                'phone' => '+243901234576',
                'password' => Hash::make('Survivant2Secure123!'),
                'role_id' => $roles['survivante']->id,
                'first_name' => 'Anonyme',
                'last_name' => 'Survivante2',
                'is_active' => true,
                'email_verified_at' => null,
                'phone_verified_at' => now(),
                'created_at' => now(),
                'updated_at' => now()
            ]
        ];

        // Insertion des utilisateurs
        foreach ($users as $user) {
            DB::table('users')->updateOrInsert(
                ['email' => $user['email'], 'phone' => $user['phone']], 
                $user
            );
        }
        
        $this->command->info('✅ Utilisateurs de test créés pour tous les profils');
        $this->command->info('📱 Survivantes: Authentification par téléphone + mot de passe');
        $this->command->info('💻 Professionnels: Authentification par email + mot de passe');
    }
}