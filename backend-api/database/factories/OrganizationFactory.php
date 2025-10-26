<?php

namespace Database\Factories;

use App\Models\Organization;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * Factory pour le modèle Organization
 */
class OrganizationFactory extends Factory
{
    protected $model = Organization::class;

    public function definition(): array
    {
        $types = ['ngo', 'government', 'international', 'religious', 'community'];
        $type = $this->faker->randomElement($types);
        
        return [
            'name' => $this->faker->company() . ' ' . $this->getTypeSuffix($type),
            'type' => $type,
            'description' => $this->faker->paragraph(),
            'email' => $this->faker->unique()->companyEmail(),
            'phone' => '+243' . $this->faker->numerify('#########'),
            'address' => $this->faker->address(),
            'city' => $this->faker->randomElement([
                'Kinshasa', 'Lubumbashi', 'Mbuji-Mayi', 'Kananga', 'Kisangani',
                'Bukavu', 'Tshikapa', 'Kolwezi', 'Likasi', 'Boma'
            ]),
            'province' => $this->faker->randomElement([
                'Kinshasa', 'Haut-Katanga', 'Kasaï-Oriental', 'Kasaï-Central',
                'Tshopo', 'Sud-Kivu', 'Kasaï', 'Lualaba', 'Haut-Lomami', 'Kongo-Central'
            ]),
            'country' => 'République Démocratique du Congo',
            'website' => $this->faker->optional(0.7)->url(),
            'registration_number' => $this->faker->optional(0.8)->numerify('REG-####-####'),
            'is_active' => true,
            'created_at' => $this->faker->dateTimeBetween('-2 years'),
            'updated_at' => now(),
        ];
    }

    private function getTypeSuffix(string $type): string
    {
        return match ($type) {
            'ngo' => 'ONG',
            'government' => 'Ministère',
            'international' => 'International',
            'religious' => 'Église',
            'community' => 'Communautaire',
            default => 'Organisation',
        };
    }

    public function ngo(): static
    {
        return $this->state(fn (array $attributes) => [
            'type' => 'ngo',
            'name' => $this->faker->company() . ' ONG',
        ]);
    }

    public function government(): static
    {
        return $this->state(fn (array $attributes) => [
            'type' => 'government',
            'name' => 'Ministère de ' . $this->faker->randomElement([
                'la Santé Publique',
                'l\'Éducation',
                'la Justice',
                'l\'Intérieur',
                'la Défense',
                'la Condition Féminine'
            ]),
        ]);
    }

    public function international(): static
    {
        return $this->state(fn (array $attributes) => [
            'type' => 'international',
            'name' => $this->faker->randomElement([
                'UNICEF RDC',
                'UNFPA Congo',
                'OMS Congo',
                'UNHCR RDC',
                'Save the Children',
                'Médecins Sans Frontières'
            ]),
        ]);
    }

    public function inactive(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => false,
        ]);
    }
}