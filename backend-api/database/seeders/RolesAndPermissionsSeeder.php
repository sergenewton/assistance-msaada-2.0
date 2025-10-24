<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class RolesAndPermissionsSeeder extends Seeder
{
    /**
     * Seed des rôles et permissions pour ASSISTANCE MSAADA 2.0
     */
    public function run(): void
    {
        // Insertion des rôles
        $roles = [
            ['name' => 'admin', 'display_name' => 'Administrateur Système'],
            ['name' => 'superviseur', 'display_name' => 'Superviseur'],
            ['name' => 'aps', 'display_name' => 'Agent de Protection Sociale'],
            ['name' => 'operateur', 'display_name' => 'Opérateur de Saisie'],
            ['name' => 'organisation', 'display_name' => 'Représentant Organisation'],
            ['name' => 'survivante', 'display_name' => 'Survivante'],
        ];

        foreach ($roles as $role) {
            DB::table('roles')->updateOrInsert(['name' => $role['name']], $role);
        }

        // Insertion des permissions
        $permissions = [
            ['name' => 'view_dashboard', 'description' => 'Voir le tableau de bord'],
            ['name' => 'manage_users', 'description' => 'Gérer les utilisateurs'],
            ['name' => 'view_reports', 'description' => 'Voir les signalements'],
            ['name' => 'create_reports', 'description' => 'Créer des signalements'],
            ['name' => 'edit_reports', 'description' => 'Modifier des signalements'],
            ['name' => 'assign_cases', 'description' => 'Assigner des cas'],
            ['name' => 'manage_organizations', 'description' => 'Gérer les organisations'],
            ['name' => 'view_analytics', 'description' => 'Voir les analyses'],
            ['name' => 'manage_content', 'description' => 'Gérer le contenu'],
            ['name' => 'export_data', 'description' => 'Exporter les données'],
            ['name' => 'system_config', 'description' => 'Configuration système'],
            ['name' => 'manage_referrals', 'description' => 'Gérer les référencements'],
            ['name' => 'view_audit_logs', 'description' => 'Voir les logs d\'audit'],
            ['name' => 'send_messages', 'description' => 'Envoyer des messages'],
            ['name' => 'view_sensitive_data', 'description' => 'Voir les données sensibles'],
        ];

        foreach ($permissions as $permission) {
            DB::table('permissions')->updateOrInsert(['name' => $permission['name']], $permission);
        }

        // Attribution des permissions aux rôles
        $rolePermissions = [
            'admin' => [
                'view_dashboard', 'manage_users', 'view_reports', 'create_reports', 'edit_reports',
                'assign_cases', 'manage_organizations', 'view_analytics', 'manage_content',
                'export_data', 'system_config', 'manage_referrals', 'view_audit_logs',
                'send_messages', 'view_sensitive_data'
            ],
            'superviseur' => [
                'view_dashboard', 'view_reports', 'assign_cases', 'view_analytics',
                'manage_referrals', 'view_audit_logs', 'send_messages', 'view_sensitive_data'
            ],
            'aps' => [
                'view_dashboard', 'view_reports', 'create_reports', 'edit_reports',
                'manage_referrals', 'send_messages'
            ],
            'operateur' => [
                'view_dashboard', 'view_reports', 'create_reports', 'edit_reports'
            ],
            'organisation' => [
                'view_dashboard', 'view_reports', 'manage_referrals', 'send_messages'
            ],
            'survivante' => [
                'view_dashboard', 'create_reports', 'send_messages'
            ]
        ];

        foreach ($rolePermissions as $roleName => $permissions) {
            $role = DB::table('roles')->where('name', $roleName)->first();
            if ($role) {
                foreach ($permissions as $permissionName) {
                    $permission = DB::table('permissions')->where('name', $permissionName)->first();
                    if ($permission) {
                        DB::table('role_permissions')->updateOrInsert([
                            'role_id' => $role->id,
                            'permission_id' => $permission->id
                        ]);
                    }
                }
            }
        }
    }
}