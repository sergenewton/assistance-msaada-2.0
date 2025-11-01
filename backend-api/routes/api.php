<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {
    // Health check endpoint
    Route::get('/health', function () {
        return new \Illuminate\Http\JsonResponse([
            'status' => 'ok',
            'timestamp' => now()->toISOString(),
            'service' => 'Assistance Msaada API',
            'version' => '2.0.0'
        ]);
    });
    
    // Public, no-auth reporting routes
    $publicRoutes = __DIR__ . '/api/v1/public.php';
    if (!file_exists($publicRoutes)) {
        $publicRoutes = __DIR__ . '/v1/public.php';
    }
    if (file_exists($publicRoutes)) {
        require_once $publicRoutes;
    }

    // Include (optional) auth routes if present
    $authRoutes = __DIR__ . '/api/v1/auth.php';
    if (!file_exists($authRoutes)) {
        $authRoutes = __DIR__ . '/v1/auth.php';
    }
    if (file_exists($authRoutes)) {
        require_once $authRoutes;
    }

    // Include (optional) protected reports routes if present
    $reportsRoutes = __DIR__ . '/api/v1/reports.php';
    if (!file_exists($reportsRoutes)) {
        $reportsRoutes = __DIR__ . '/v1/reports.php';
    }
    if (file_exists($reportsRoutes)) {
        require_once $reportsRoutes;
    }

    // Debug endpoints removed after validation
});

// Global health check (without version)
Route::get('/health', function () {
    return new \Illuminate\Http\JsonResponse([
        'status' => 'ok',
        'timestamp' => now()->toISOString(),
        'service' => 'Assistance Msaada API',
        'version' => '2.0.0'
    ]);
});