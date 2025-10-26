<?php

namespace Database\Factories;

use App\Models\Role;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * Factory pour le modèle Role
 */
class RoleFactory extends Factory
{
    protected $model = Role::class;

    public function definition(): array
    {
        return [
            'name' => $this->faker->unique()->randomElement([
                'survivante', 'aps', 'operateur', 'organisation', 'superviseur', 'admin'
            ]),
            'display_name' => function (array $attributes) {
                return ucfirst($attributes['name']);
            },
            'description' => function (array $attributes) {
                return "Rôle pour les utilisateurs {$attributes['name']}";
            },
            'created_at' => now(),
            'updated_at' => now(),
        ];
    }

    public function survivante(): static
    {
        return $this->state(fn (array $attributes) => [
            'name' => 'survivante',
            'display_name' => 'Survivante',
            'description' => 'Rôle pour les survivantes de violences basées sur le genre',
        ]);
    }

    public function aps(): static
    {
        return $this->state(fn (array $attributes) => [
            'name' => 'aps',
            'display_name' => 'Agent de Protection Sociale',
            'description' => 'Rôle pour les agents de protection sociale',
        ]);
    }

    public function operateur(): static
    {
        return $this->state(fn (array $attributes) => [
            'name' => 'operateur',
            'display_name' => 'Opérateur',
            'description' => 'Rôle pour les opérateurs du système',
        ]);
    }

    public function organisation(): static
    {
        return $this->state(fn (array $attributes) => [
            'name' => 'organisation',
            'display_name' => 'Organisation',
            'description' => 'Rôle pour les représentants d\'organisations',
        ]);
    }

    public function superviseur(): static
    {
        return $this->state(fn (array $attributes) => [
            'name' => 'superviseur',
            'display_name' => 'Superviseur',
            'description' => 'Rôle pour les superviseurs du système',
        ]);
    }

    public function admin(): static
    {
        return $this->state(fn (array $attributes) => [
            'name' => 'admin',
            'display_name' => 'Administrateur',
            'description' => 'Rôle pour les administrateurs système',
        ]);
    }
}