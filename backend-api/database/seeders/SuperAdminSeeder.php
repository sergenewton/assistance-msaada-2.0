<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class SuperAdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Vérifier si un admin existe déjà
        $adminRole = DB::table('roles')->where('name', 'admin')->first();
        
        if (!$adminRole) {
            // Créer le rôle admin s'il n'existe pas
            $adminRole = DB::table('roles')->insertGetId([
                'name' => 'admin',
                'display_name' => 'Super Administrateur',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        } else {
            $adminRole = $adminRole->id;
        }

        // Vérifier si un super admin existe déjà
        $existingAdmin = DB::table('users')
            ->where('role_id', $adminRole)
            ->first();

        if (!$existingAdmin) {
            // Créer le compte super admin
            $adminId = Str::uuid();
            
            DB::table('users')->insert([
                'id' => $adminId,
                'email' => encrypt('admin@msaada.cd'), // Email chiffré
                'phone' => encrypt('+243000000000'), // Téléphone chiffré
                'password' => Hash::make('Admin@2025!'), // Mot de passe fort
                'role_id' => $adminRole,
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

            $this->command->info('Super Admin créé avec succès !');
            $this->command->info('Email: admin@msaada.cd');
            $this->command->info('Mot de passe: Admin@2025!');
            $this->command->warn('IMPORTANT: Changez ce mot de passe dès la première connexion');
        } else {
            $this->command->info('Un compte super admin existe déjà.');
        }
    }
}