<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

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
            ]
        ];

        // Insertion des utilisateurs
        foreach ($users as $user) {
            $user['id'] = Str::uuid();
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