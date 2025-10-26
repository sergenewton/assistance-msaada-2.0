<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class RolesAndPermissionsSeeder extends Seeder
{
    /**
     * Seed des rôles et permissions pour ASSISTANCE MSAADA 2.0
     * Basé sur les 6 profils d'acteurs définis
     */
    public function run(): void
    {
        // Insertion des rôles selon les profils définis
        $roles = [
            ['name' => 'survivante', 'display_name' => 'Survivante / Témoin'],
            ['name' => 'aps', 'display_name' => 'Agent Psychosocial (APS)'],
            ['name' => 'operateur', 'display_name' => 'Opérateur Centre d\'Écoute'],
            ['name' => 'organisation', 'display_name' => 'Organisation Partenaire'],
            ['name' => 'admin', 'display_name' => 'Administrateur Système'],
            ['name' => 'superviseur', 'display_name' => 'Superviseur / Coordinateur'],
        ];

        foreach ($roles as $role) {
            DB::table('roles')->updateOrInsert(['name' => $role['name']], $role);
        }

        // Insertion des permissions détaillées par profil
        $permissions = [
            // Permissions Survivante/Témoin
            ['name' => 'reports.create', 'description' => 'Créer un signalement (anonyme ou nominatif)'],
            ['name' => 'reports.view_own_status', 'description' => 'Consulter le statut de son cas'],
            ['name' => 'messages.send_to_aps', 'description' => 'Communiquer avec son APS assigné'],
            ['name' => 'alerts.receive', 'description' => 'Recevoir des alertes et rappels'],
            ['name' => 'resources.access_awareness', 'description' => 'Accéder aux ressources de sensibilisation'],
            ['name' => 'feedback.submit_quality', 'description' => 'Évaluer la qualité de la prise en charge'],
            
            // Permissions Agent Psychosocial (APS)
            ['name' => 'cases.view_assigned', 'description' => 'Visualiser les cas qui lui sont assignés'],
            ['name' => 'messages.secure_chat', 'description' => 'Communiquer avec la survivante (chat sécurisé)'],
            ['name' => 'cases.update_status', 'description' => 'Mettre à jour le statut de prise en charge'],
            ['name' => 'sessions.document', 'description' => 'Documenter les séances d\'accompagnement'],
            ['name' => 'referrals.request', 'description' => 'Solliciter des référencements complémentaires'],
            ['name' => 'reports.generate_progress', 'description' => 'Générer des rapports d\'étape'],
            
            // Permissions Opérateur Centre d'Écoute
            ['name' => 'reports.receive_all', 'description' => 'Recevoir et triager tous les signalements'],
            ['name' => 'cases.evaluate_urgency', 'description' => 'Évaluer le niveau d\'urgence et de danger'],
            ['name' => 'referrals.create', 'description' => 'Référencer les cas vers les organisations compétentes'],
            ['name' => 'cases.assign_aps', 'description' => 'Assigner un APS à chaque cas'],
            ['name' => 'cases.monitor_progress', 'description' => 'Suivre l\'évolution globale des cas'],
            ['name' => 'organizations.follow_up', 'description' => 'Relancer les organisations en cas de retard'],
            ['name' => 'cases.validate_closure', 'description' => 'Valider la clôture des cas'],
            
            // Permissions Organisation Partenaire
            ['name' => 'referrals.receive', 'description' => 'Recevoir les cas référencés dans leur domaine'],
            ['name' => 'referrals.accept_decline', 'description' => 'Accepter ou décliner une prise en charge (avec justification)'],
            ['name' => 'cases.update_progress', 'description' => 'Mettre à jour le statut d\'avancement'],
            ['name' => 'documents.upload', 'description' => 'Uploader des documents (certificats médicaux, PV, etc.)'],
            ['name' => 'referrals.cross_reference', 'description' => 'Proposer des référencements croisés'],
            ['name' => 'cases.view_history', 'description' => 'Consulter l\'historique des cas traités'],
            
            // Permissions Administrateur Système
            ['name' => 'users.manage_all', 'description' => 'Gérer tous les utilisateurs et leurs accès'],
            ['name' => 'system.configure', 'description' => 'Configurer les paramètres système'],
            ['name' => 'organizations.manage', 'description' => 'Gérer les organisations partenaires'],
            ['name' => 'audit.view_logs', 'description' => 'Consulter les logs d\'audit'],
            ['name' => 'backups.manage', 'description' => 'Gérer les sauvegardes'],
            ['name' => 'notifications.configure', 'description' => 'Configurer les alertes et notifications'],
            ['name' => 'content.manage_awareness', 'description' => 'Gérer les contenus de sensibilisation'],
            ['name' => 'data.extract_anonymized', 'description' => 'Extraire des données anonymisées pour recherche'],
            
            // Permissions Superviseur/Coordinateur
            ['name' => 'dashboard.full_access', 'description' => 'Accès complet aux tableaux de bord'],
            ['name' => 'cases.view_all', 'description' => 'Vue consolidée de tous les cas'],
            ['name' => 'reports.strategic', 'description' => 'Génération de rapports stratégiques'],
            ['name' => 'performance.monitor', 'description' => 'Supervision des performances (temps de réponse, etc.)'],
            ['name' => 'cases.reassign', 'description' => 'Réaffectation de cas en cas de problème'],
            ['name' => 'statistics.export_anonymized', 'description' => 'Export de données statistiques anonymisées'],
            
            // Permissions communes
            ['name' => 'dashboard.view', 'description' => 'Accès au tableau de bord de base'],
            ['name' => 'profile.manage', 'description' => 'Gérer son profil utilisateur'],
        ];

        foreach ($permissions as $permission) {
            DB::table('permissions')->updateOrInsert(['name' => $permission['name']], $permission);
        }

        // Attribution des permissions aux rôles selon les profils détaillés
        $rolePermissions = [
            'survivante' => [
                // Survivante / Témoin - Accès : Application mobile
                'dashboard.view',
                'profile.manage',
                'reports.create',
                'reports.view_own_status',
                'messages.send_to_aps',
                'alerts.receive',
                'resources.access_awareness',
                'feedback.submit_quality'
            ],
            
            'aps' => [
                // Agent Psychosocial (APS) - Accès : Application web + mobile
                'dashboard.view',
                'profile.manage',
                'cases.view_assigned',
                'messages.secure_chat',
                'cases.update_status',
                'sessions.document',
                'referrals.request',
                'reports.generate_progress'
            ],
            
            'operateur' => [
                // Opérateur Centre d'Écoute - Accès : Application web
                'dashboard.view',
                'profile.manage',
                'reports.receive_all',
                'cases.evaluate_urgency',
                'referrals.create',
                'cases.assign_aps',
                'cases.monitor_progress',
                'organizations.follow_up',
                'cases.validate_closure'
            ],
            
            'organisation' => [
                // Organisation Partenaire - Accès : Application web (portail dédié)
                'dashboard.view',
                'profile.manage',
                'referrals.receive',
                'referrals.accept_decline',
                'cases.update_progress',
                'documents.upload',
                'referrals.cross_reference',
                'cases.view_history'
            ],
            
            'admin' => [
                // Administrateur Système - Accès : Application web (panneau admin)
                'dashboard.view',
                'profile.manage',
                'users.manage_all',
                'system.configure',
                'organizations.manage',
                'audit.view_logs',
                'backups.manage',
                'notifications.configure',
                'content.manage_awareness',
                'data.extract_anonymized',
                // Accès à toutes les autres permissions pour maintenance
                'dashboard.full_access',
                'cases.view_all',
                'reports.strategic',
                'performance.monitor',
                'cases.reassign',
                'statistics.export_anonymized'
            ],
            
            'superviseur' => [
                // Superviseur / Coordinateur - Accès : Application web (vue d'ensemble)
                'dashboard.view',
                'profile.manage',
                'dashboard.full_access',
                'cases.view_all',
                'reports.strategic',
                'performance.monitor',
                'cases.reassign',
                'statistics.export_anonymized'
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