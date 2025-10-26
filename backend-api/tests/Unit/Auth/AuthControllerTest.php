<?php

namespace Tests\Unit\Auth;

use Tests\TestCase;
use App\Models\User;
use App\Models\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;
use Laravel\Sanctum\Sanctum;

/**
 * Tests unitaires pour AuthController
 * Couvre tous les endpoints d'authentification avec scénarios VBG
 */
class AuthControllerTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Créer les rôles de base
        $this->createRoles();
        
        // Désactiver les middlewares de rate limiting pour les tests
        RateLimiter::clear('login');
    }

    private function createRoles(): void
    {
        $roles = ['survivante', 'aps', 'operateur', 'organisation', 'superviseur', 'admin'];
        
        foreach ($roles as $role) {
            Role::factory()->create([
                'name' => $role,
                'display_name' => ucfirst($role),
                'description' => "Rôle {$role}",
            ]);
        }
    }

    /** @test */
    public function test_register_successful_with_valid_data()
    {
        $roleId = Role::where('name', 'survivante')->first()->id;
        
        $userData = [
            'email' => 'survivor@example.com',
            'password' => 'SecurePass123!',
            'password_confirmation' => 'SecurePass123!',
            'role' => 'survivante',
            'terms_accepted' => true,
            'privacy_policy_accepted' => true,
        ];

        $response = $this->postJson('/api/v1/auth/register', $userData);

        $response->assertStatus(201)
                 ->assertJsonStructure([
                     'success',
                     'message',
                     'data' => [
                         'user' => [
                             'id',
                             'email',
                             'role',
                             'role_display_name',
                             'permissions',
                         ],
                         'token' => [
                             'access_token',
                             'token_type',
                             'expires_at',
                         ]
                     ]
                 ]);

        $this->assertDatabaseHas('users', [
            'email' => 'survivor@example.com',
            'role_id' => $roleId,
        ]);
    }

    /** @test */
    public function test_register_fails_with_invalid_email()
    {
        $userData = [
            'email' => 'invalid-email',
            'password' => 'SecurePass123!',
            'password_confirmation' => 'SecurePass123!',
            'role' => 'survivante',
            'terms_accepted' => true,
            'privacy_policy_accepted' => true,
        ];

        $response = $this->postJson('/api/v1/auth/register', $userData);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['email']);
    }

    /** @test */
    public function test_register_fails_with_weak_password()
    {
        $userData = [
            'email' => 'test@example.com',
            'password' => '123456', // Mot de passe faible
            'password_confirmation' => '123456',
            'role' => 'survivante',
            'terms_accepted' => true,
            'privacy_policy_accepted' => true,
        ];

        $response = $this->postJson('/api/v1/auth/register', $userData);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['password']);
    }

    /** @test */
    public function test_register_fails_without_terms_acceptance()
    {
        $userData = [
            'email' => 'test@example.com',
            'password' => 'SecurePass123!',
            'password_confirmation' => 'SecurePass123!',
            'role' => 'survivante',
            'terms_accepted' => false, // Conditions non acceptées
            'privacy_policy_accepted' => true,
        ];

        $response = $this->postJson('/api/v1/auth/register', $userData);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['terms_accepted']);
    }

    /** @test */
    public function test_login_successful_with_email()
    {
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => Hash::make('password123'),
            'role_id' => Role::where('name', 'survivante')->first()->id,
        ]);

        $loginData = [
            'identifier' => 'test@example.com',
            'password' => 'password123',
            'device_name' => 'Test Device',
        ];

        $response = $this->postJson('/api/v1/auth/login', $loginData);

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'success',
                     'message',
                     'data' => [
                         'user' => [
                             'id',
                             'email',
                             'role',
                             'permissions',
                         ],
                         'token' => [
                             'access_token',
                             'token_type',
                             'expires_at',
                         ]
                     ]
                 ]);
    }

    /** @test */
    public function test_login_successful_with_phone()
    {
        $user = User::factory()->create([
            'phone' => '+243901234567',
            'password' => Hash::make('password123'),
            'role_id' => Role::where('name', 'survivante')->first()->id,
        ]);

        $loginData = [
            'identifier' => '+243901234567',
            'password' => 'password123',
            'device_name' => 'Test Device',
        ];

        $response = $this->postJson('/api/v1/auth/login', $loginData);

        $response->assertStatus(200);
    }

    /** @test */
    public function test_login_fails_with_invalid_credentials()
    {
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => Hash::make('correct_password'),
            'role_id' => Role::where('name', 'survivante')->first()->id,
        ]);

        $loginData = [
            'identifier' => 'test@example.com',
            'password' => 'wrong_password',
            'device_name' => 'Test Device',
        ];

        $response = $this->postJson('/api/v1/auth/login', $loginData);

        $response->assertStatus(401)
                 ->assertJson([
                     'success' => false,
                     'message' => 'Identifiants invalides',
                 ]);
    }

    /** @test */
    public function test_logout_successful()
    {
        $user = User::factory()->create([
            'role_id' => Role::where('name', 'survivante')->first()->id,
        ]);
        
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/v1/auth/logout');

        $response->assertStatus(200)
                 ->assertJson([
                     'success' => true,
                     'message' => 'Déconnexion réussie',
                 ]);
    }

    /** @test */
    public function test_logout_fails_without_authentication()
    {
        $response = $this->postJson('/api/v1/auth/logout');

        $response->assertStatus(401);
    }

    /** @test */
    public function test_me_returns_user_data()
    {
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'role_id' => Role::where('name', 'survivante')->first()->id,
        ]);
        
        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/auth/me');

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'success',
                     'data' => [
                         'user' => [
                             'id',
                             'email',
                             'role',
                             'permissions',
                         ]
                     ]
                 ]);
    }

    /** @test */
    public function test_refresh_token_successful()
    {
        $user = User::factory()->create([
            'role_id' => Role::where('name', 'survivante')->first()->id,
        ]);
        
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/v1/auth/refresh');

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'success',
                     'data' => [
                         'user',
                         'token' => [
                             'access_token',
                             'token_type',
                             'expires_at',
                         ]
                     ]
                 ]);
    }

    /** @test */
    public function test_verify_token_successful()
    {
        $user = User::factory()->create([
            'role_id' => Role::where('name', 'survivante')->first()->id,
        ]);
        
        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/auth/verify');

        $response->assertStatus(200)
                 ->assertJson([
                     'success' => true,
                     'data' => [
                         'valid' => true,
                     ]
                 ]);
    }

    /** @test */
    public function test_verify_token_fails_without_authentication()
    {
        $response = $this->getJson('/api/v1/auth/verify');

        $response->assertStatus(401);
    }

    /** @test */
    public function test_register_with_organization_role_requires_organization_id()
    {
        $userData = [
            'email' => 'org@example.com',
            'password' => 'SecurePass123!',
            'password_confirmation' => 'SecurePass123!',
            'role' => 'organisation',
            'terms_accepted' => true,
            'privacy_policy_accepted' => true,
            // organization_id manquant
        ];

        $response = $this->postJson('/api/v1/auth/register', $userData);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['organization_id']);
    }

    /** @test */
    public function test_phone_registration_with_valid_drc_number()
    {
        $userData = [
            'phone' => '+243901234567', // Numéro DRC valide
            'password' => 'SecurePass123!',
            'password_confirmation' => 'SecurePass123!',
            'role' => 'survivante',
            'terms_accepted' => true,
            'privacy_policy_accepted' => true,
        ];

        $response = $this->postJson('/api/v1/auth/register', $userData);

        $response->assertStatus(201);
    }

    /** @test */
    public function test_phone_registration_fails_with_invalid_format()
    {
        $userData = [
            'phone' => '0901234567', // Format invalide (manque +243)
            'password' => 'SecurePass123!',
            'password_confirmation' => 'SecurePass123!',
            'role' => 'survivante',
            'terms_accepted' => true,
            'privacy_policy_accepted' => true,
        ];

        $response = $this->postJson('/api/v1/auth/register', $userData);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['phone']);
    }
}