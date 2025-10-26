<?php

namespace Database\Factories;

use App\Models\Permission;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * Factory pour le modèle Permission
 */
class PermissionFactory extends Factory
{
    protected $model = Permission::class;

    public function definition(): array
    {
        return [
            'name' => $this->faker->unique()->randomElement([
                'reports.view', 'reports.create', 'reports.edit', 'reports.delete',
                'users.view', 'users.create', 'users.edit', 'users.delete', 'users.manage',
                'analytics.view', 'analytics.export',
                'organizations.view', 'organizations.manage',
                'system.settings', 'system.logs'
            ]),
            'display_name' => function (array $attributes) {
                return str_replace(['_', '.'], ' ', ucwords($attributes['name'], '_.'));
            },
            'description' => function (array $attributes) {
                return "Permission pour {$attributes['name']}";
            },
            'created_at' => now(),
            'updated_at' => now(),
        ];
    }

    // Permissions pour les rapports
    public function reportsView(): static
    {
        return $this->state(fn (array $attributes) => [
            'name' => 'reports.view',
            'display_name' => 'Voir les rapports',
            'description' => 'Permission de visualiser les rapports VBG',
        ]);
    }

    public function reportsCreate(): static
    {
        return $this->state(fn (array $attributes) => [
            'name' => 'reports.create',
            'display_name' => 'Créer des rapports',
            'description' => 'Permission de créer de nouveaux rapports VBG',
        ]);
    }

    // Permissions pour les utilisateurs
    public function usersManage(): static
    {
        return $this->state(fn (array $attributes) => [
            'name' => 'users.manage',
            'display_name' => 'Gérer les utilisateurs',
            'description' => 'Permission de gérer les comptes utilisateurs',
        ]);
    }

    // Permissions pour les analyses
    public function analyticsView(): static
    {
        return $this->state(fn (array $attributes) => [
            'name' => 'analytics.view',
            'display_name' => 'Voir les analyses',
            'description' => 'Permission de visualiser les tableaux de bord et analyses',
        ]);
    }
}