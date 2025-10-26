<?php

namespace Tests\Unit\Auth;

use Tests\TestCase;
use App\Models\User;
use App\Models\Role;
use App\Models\Permission;
use App\Http\Middleware\CheckPermission;
use App\Http\Middleware\CheckRole;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Laravel\Sanctum\Sanctum;
use Symfony\Component\HttpFoundation\Response as HttpResponse;

/**
 * Tests unitaires pour les middlewares d'authentification RBAC
 */
class AuthMiddlewareTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->createRolesAndPermissions();
    }

    private function createRolesAndPermissions(): void
    {
        // Créer les rôles
        $survivorRole = Role::factory()->create(['name' => 'survivante']);
        $adminRole = Role::factory()->create(['name' => 'admin']);
        $operatorRole = Role::factory()->create(['name' => 'operateur']);

        // Créer les permissions
        $reportsView = Permission::factory()->create(['name' => 'reports.view']);
        $reportsCreate = Permission::factory()->create(['name' => 'reports.create']);
        $usersManage = Permission::factory()->create(['name' => 'users.manage']);

        // Attribuer des permissions aux rôles
        $survivorRole->permissions()->attach([$reportsView->id, $reportsCreate->id]);
        $operatorRole->permissions()->attach([$reportsView->id, $usersManage->id]);
        $adminRole->permissions()->attach([$reportsView->id, $reportsCreate->id, $usersManage->id]);
    }

    /** @test */
    public function test_check_permission_middleware_allows_access_with_valid_permission()
    {
        // Créer un utilisateur avec le rôle survivante
        $user = User::factory()->create([
            'role_id' => Role::where('name', 'survivante')->first()->id,
        ]);

        Sanctum::actingAs($user);

        $request = Request::create('/test', 'GET');
        $middleware = new CheckPermission();

        $response = $middleware->handle($request, function ($req) {
            return new Response('Success', 200);
        }, 'reports.view');

        $this->assertEquals(200, $response->getStatusCode());
    }

    /** @test */
    public function test_check_permission_middleware_denies_access_without_permission()
    {
        // Créer un utilisateur avec le rôle survivante (n'a pas users.manage)
        $user = User::factory()->create([
            'role_id' => Role::where('name', 'survivante')->first()->id,
        ]);

        Sanctum::actingAs($user);

        $request = Request::create('/test', 'GET');
        $middleware = new CheckPermission();

        $response = $middleware->handle($request, function ($req) {
            return new Response('Success', 200);
        }, 'users.manage');

        $this->assertEquals(403, $response->getStatusCode());
    }

    /** @test */
    public function test_check_permission_middleware_allows_admin_all_permissions()
    {
        // Admin a tous les droits
        $user = User::factory()->create([
            'role_id' => Role::where('name', 'admin')->first()->id,
        ]);

        Sanctum::actingAs($user);

        $request = Request::create('/test', 'GET');
        $middleware = new CheckPermission();

        // Test avec n'importe quelle permission
        $response = $middleware->handle($request, function ($req) {
            return new Response('Success', 200);
        }, 'any.permission');

        $this->assertEquals(200, $response->getStatusCode());
    }

    /** @test */
    public function test_check_role_middleware_allows_access_with_correct_role()
    {
        $user = User::factory()->create([
            'role_id' => Role::where('name', 'survivante')->first()->id,
        ]);

        Sanctum::actingAs($user);

        $request = Request::create('/test', 'GET');
        $middleware = new CheckRole();

        $response = $middleware->handle($request, function ($req) {
            return new Response('Success', 200);
        }, 'survivante');

        $this->assertEquals(200, $response->getStatusCode());
    }

    /** @test */
    public function test_check_role_middleware_denies_access_with_wrong_role()
    {
        $user = User::factory()->create([
            'role_id' => Role::where('name', 'survivante')->first()->id,
        ]);

        Sanctum::actingAs($user);

        $request = Request::create('/test', 'GET');
        $middleware = new CheckRole();

        $response = $middleware->handle($request, function ($req) {
            return new Response('Success', 200);
        }, 'admin');

        $this->assertEquals(403, $response->getStatusCode());
    }

    /** @test */
    public function test_check_role_middleware_allows_multiple_roles()
    {
        $user = User::factory()->create([
            'role_id' => Role::where('name', 'operateur')->first()->id,
        ]);

        Sanctum::actingAs($user);

        $request = Request::create('/test', 'GET');
        $middleware = new CheckRole();

        $response = $middleware->handle($request, function ($req) {
            return new Response('Success', 200);
        }, 'survivante|operateur|admin');

        $this->assertEquals(200, $response->getStatusCode());
    }

    /** @test */
    public function test_middleware_denies_access_for_unauthenticated_user()
    {
        $request = Request::create('/test', 'GET');
        $middleware = new CheckPermission();

        $response = $middleware->handle($request, function ($req) {
            return new Response('Success', 200);
        }, 'reports.view');

        $this->assertEquals(401, $response->getStatusCode());
    }

    /** @test */
    public function test_middleware_logs_permission_violations()
    {
        $user = User::factory()->create([
            'role_id' => Role::where('name', 'survivante')->first()->id,
        ]);

        Sanctum::actingAs($user);

        $request = Request::create('/test', 'GET');
        $middleware = new CheckPermission();

        // Mock du logger pour vérifier que la violation est loggée
        \Log::shouldReceive('warning')
           ->once()
           ->with(\Mockery::pattern('/Permission denied/'));

        $response = $middleware->handle($request, function ($req) {
            return new Response('Success', 200);
        }, 'users.manage');

        $this->assertEquals(403, $response->getStatusCode());
    }
}