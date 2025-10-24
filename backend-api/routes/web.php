<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Routes web pour l'interface administrateur ou toute autre interface web
| Ces routes utilisent les middlewares web par défaut de Laravel
|
*/

Route::get('/', function () {
    return response()->json([
        'message' => 'VBG Platform API',
        'version' => 'v1.0.0',
        'status' => 'active',
        'timestamp' => now()->toISOString()
    ]);
})->name('home');

Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now()->toISOString(),
        'services' => [
            'database' => 'connected',
            'cache' => 'available',
            'storage' => 'writable'
        ]
    ]);
})->name('health-check');