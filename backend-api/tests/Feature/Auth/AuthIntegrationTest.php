<?php

namespace Tests\Feature\Auth;

use Tests\TestCase;
use App\Models\User;
use App\Models\Role;
use App\Models\Organization;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\Sanctum;

/**
 * Tests d'intégration pour l'API d'authentification
 * Couvre les flux complets d'authentification VBG
 */
class AuthIntegrationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->artisan('db:seed', ['--class' => 'RolesAndPermissionsSeeder']);
    }

    /** @test */
    public function test_complete_survivor_registration_and_login_flow()
    {
        // 1. Inscription d'une survivante
        $registrationData = [
            'email' => 'survivor@example.com',
            'password' => 'SecurePass123!',
            'password_confirmation' => 'SecurePass123!',
            'role' => 'survivante',
            'terms_accepted' => true,
            'privacy_policy_accepted' => true,
        ];

        $registerResponse = $this->postJson('/api/v1/auth/register', $registrationData);
        
        $registerResponse->assertStatus(201);
        $registerData = $registerResponse->json();
        
        $this->assertArrayHasKey('data', $registerData);
        $this->assertArrayHasKey('token', $registerData['data']);
        
        $token = $registerData['data']['token']['access_token'];

        // 2. Utilisation du token pour accéder aux données utilisateur
        $meResponse = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->getJson('/api/v1/auth/me');

        $meResponse->assertStatus(200);
        $userData = $meResponse->json();
        
        $this->assertEquals('survivor@example.com', $userData['data']['user']['email']);
        $this->assertEquals('survivante', $userData['data']['user']['role']);

        // 3. Déconnexion
        $logoutResponse = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->postJson('/api/v1/auth/logout');

        $logoutResponse->assertStatus(200);

        // 4. Vérification que le token est invalidé
        $invalidTokenResponse = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->getJson('/api/v1/auth/me');

        $invalidTokenResponse->assertStatus(401);

        // 5. Nouvelle connexion avec email/mot de passe
        $loginData = [
            'identifier' => 'survivor@example.com',
            'password' => 'SecurePass123!',
            'device_name' => 'Test Device'
        ];

        $loginResponse = $this->postJson('/api/v1/auth/login', $loginData);
        
        $loginResponse->assertStatus(200);
        $newToken = $loginResponse->json()['data']['token']['access_token'];

        // 6. Vérification du nouveau token
        $newMeResponse = $this->withHeaders([
            'Authorization' => 'Bearer ' . $newToken,
        ])->getJson('/api/v1/auth/me');

        $newMeResponse->assertStatus(200);
    }

    /** @test */
    public function test_organization_staff_registration_with_organization()
    {
        // Créer une organisation d'abord
        $organization = Organization::factory()->create([
            'name' => 'Test NGO',
            'type' => 'ngo',
        ]);

        $registrationData = [
            'email' => 'staff@testngo.org',
            'password' => 'SecurePass123!',
            'password_confirmation' => 'SecurePass123!',
            'role' => 'operateur',
            'organization_id' => $organization->id,
            'terms_accepted' => true,
            'privacy_policy_accepted' => true,
        ];

        $response = $this->postJson('/api/v1/auth/register', $registrationData);

        $response->assertStatus(201);
        
        $userData = $response->json();
        $this->assertArrayHasKey('organization', $userData['data']['user']);
        $this->assertEquals('Test NGO', $userData['data']['user']['organization']['name']);
    }

    /** @test */
    public function test_phone_registration_and_login_flow()
    {
        // Inscription avec numéro de téléphone DRC
        $registrationData = [
            'phone' => '+243901234567',
            'password' => 'SecurePass123!',
            'password_confirmation' => 'SecurePass123!',
            'role' => 'survivante',
            'terms_accepted' => true,
            'privacy_policy_accepted' => true,
        ];

        $registerResponse = $this->postJson('/api/v1/auth/register', $registrationData);
        $registerResponse->assertStatus(201);

        // Connexion avec le numéro de téléphone
        $loginData = [
            'identifier' => '+243901234567',
            'password' => 'SecurePass123!',
            'device_name' => 'Test Mobile'
        ];

        $loginResponse = $this->postJson('/api/v1/auth/login', $loginData);
        $loginResponse->assertStatus(200);

        $userData = $loginResponse->json();
        $this->assertEquals('+243901234567', $userData['data']['user']['phone']);
    }

    /** @test */
    public function test_token_refresh_flow()
    {
        $user = User::factory()->create([
            'role_id' => Role::where('name', 'survivante')->first()->id,
        ]);

        Sanctum::actingAs($user);

        // Obtenir un token initial
        $refreshResponse = $this->postJson('/api/v1/auth/refresh');
        $refreshResponse->assertStatus(200);

        $tokenData = $refreshResponse->json();
        $newToken = $tokenData['data']['token']['access_token'];

        // Utiliser le nouveau token
        $meResponse = $this->withHeaders([
            'Authorization' => 'Bearer ' . $newToken,
        ])->getJson('/api/v1/auth/me');

        $meResponse->assertStatus(200);
    }

    /** @test */
    public function test_multiple_device_login_support()
    {
        $user = User::factory()->create([
            'email' => 'multi@example.com',
            'password' => Hash::make('password123'),
            'role_id' => Role::where('name', 'survivante')->first()->id,
        ]);

        // Connexion depuis le premier appareil
        $device1Login = [
            'identifier' => 'multi@example.com',
            'password' => 'password123',
            'device_name' => 'iPhone 12'
        ];

        $device1Response = $this->postJson('/api/v1/auth/login', $device1Login);
        $device1Response->assertStatus(200);
        $device1Token = $device1Response->json()['data']['token']['access_token'];

        // Connexion depuis le second appareil
        $device2Login = [
            'identifier' => 'multi@example.com',
            'password' => 'password123',
            'device_name' => 'Samsung Galaxy'
        ];

        $device2Response = $this->postJson('/api/v1/auth/login', $device2Login);
        $device2Response->assertStatus(200);
        $device2Token = $device2Response->json()['data']['token']['access_token'];

        // Vérifier que les deux tokens fonctionnent
        $device1Check = $this->withHeaders([
            'Authorization' => 'Bearer ' . $device1Token,
        ])->getJson('/api/v1/auth/me');

        $device2Check = $this->withHeaders([
            'Authorization' => 'Bearer ' . $device2Token,
        ])->getJson('/api/v1/auth/me');

        $device1Check->assertStatus(200);
        $device2Check->assertStatus(200);

        // Déconnexion de tous les appareils
        $logoutAllResponse = $this->withHeaders([
            'Authorization' => 'Bearer ' . $device1Token,
        ])->postJson('/api/v1/auth/logout-all');

        $logoutAllResponse->assertStatus(200);

        // Vérifier que tous les tokens sont invalidés
        $device1Invalid = $this->withHeaders([
            'Authorization' => 'Bearer ' . $device1Token,
        ])->getJson('/api/v1/auth/me');

        $device2Invalid = $this->withHeaders([
            'Authorization' => 'Bearer ' . $device2Token,
        ])->getJson('/api/v1/auth/me');

        $device1Invalid->assertStatus(401);
        $device2Invalid->assertStatus(401);
    }

    /** @test */
    public function test_permission_based_access_control()
    {
        // Créer un utilisateur survivante
        $survivor = User::factory()->create([
            'role_id' => Role::where('name', 'survivante')->first()->id,
        ]);

        // Créer un admin
        $admin = User::factory()->create([
            'role_id' => Role::where('name', 'admin')->first()->id,
        ]);

        // Test d'accès survivante à une route protégée (qu'elle peut accéder)
        Sanctum::actingAs($survivor);
        
        // Simuler une route qui nécessite 'reports.create'
        $survivorAccess = $this->withHeaders([
            'X-Test-Permission' => 'reports.create'
        ])->getJson('/api/v1/auth/verify');

        $survivorAccess->assertStatus(200);

        // Test d'accès admin (peut tout faire)
        Sanctum::actingAs($admin);
        
        $adminAccess = $this->withHeaders([
            'X-Test-Permission' => 'any.permission'
        ])->getJson('/api/v1/auth/verify');

        $adminAccess->assertStatus(200);
    }

    /** @test */
    public function test_rate_limiting_on_login_attempts()
    {
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => Hash::make('correct_password'),
            'role_id' => Role::where('name', 'survivante')->first()->id,
        ]);

        // Tentatives de connexion avec mot de passe incorrect
        for ($i = 0; $i < 6; $i++) {
            $loginData = [
                'identifier' => 'test@example.com',
                'password' => 'wrong_password',
                'device_name' => 'Test Device'
            ];

            $response = $this->postJson('/api/v1/auth/login', $loginData);
            
            if ($i < 5) {
                $response->assertStatus(401);
            } else {
                // La 6ème tentative devrait être bloquée par le rate limiting
                $response->assertStatus(429);
            }
        }
    }

    /** @test */
    public function test_security_headers_and_response_format()
    {
        $loginData = [
            'identifier' => 'nonexistent@example.com',
            'password' => 'password123',
            'device_name' => 'Test Device'
        ];

        $response = $this->postJson('/api/v1/auth/login', $loginData);

        // Vérifier le format de réponse sécurisé
        $response->assertJsonStructure([
            'success',
            'message'
        ]);

        // Vérifier que les détails sensibles ne sont pas exposés
        $responseData = $response->json();
        $this->assertFalse($responseData['success']);
        $this->assertStringNotContainsString('user not found', strtolower($responseData['message']));
        $this->assertStringNotContainsString('email', strtolower($responseData['message']));
    }
}