<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;

abstract class TestCase extends BaseTestCase
{
    use CreatesApplication;
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Configuration spécifique pour les tests VBG
        $this->artisan('config:clear');
        $this->artisan('cache:clear');
    }
}