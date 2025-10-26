<?php

namespace Tests\Feature;

use Tests\TestCase;

/**
 * Test de base pour vérifier la configuration Laravel
 */
class BasicTest extends TestCase
{
    /** @test */
    public function test_application_returns_successful_response()
    {
        $response = $this->get('/');

        $response->assertStatus(200);
    }

    /** @test */
    public function test_api_health_check()
    {
        $response = $this->getJson('/api/health');

        $response->assertStatus(200)
                 ->assertJson([
                     'status' => 'ok',
                     'timestamp' => true
                 ], true);
    }
}