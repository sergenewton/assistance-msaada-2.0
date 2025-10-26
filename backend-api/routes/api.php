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
        return response()->json([
            'status' => 'ok',
            'timestamp' => now()->toISOString(),
            'service' => 'Assistance Msaada API',
            'version' => '2.0.0'
        ]);
    });
    
    // Include auth routes
    require_once __DIR__ . '/v1/auth.php';
});

// Global health check (without version)
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => now()->toISOString(),
        'service' => 'Assistance Msaada API',
        'version' => '2.0.0'
    ]);
});