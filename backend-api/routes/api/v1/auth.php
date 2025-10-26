<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Auth\AuthController;

/*
|--------------------------------------------------------------------------
| Auth API Routes
|--------------------------------------------------------------------------
|
| Routes pour l'authentification JWT avec sécurité VBG renforcée
| Phase 2: Authentification et bases
|
*/

Route::prefix('auth')->name('auth.')->group(function () {
    
    // Routes publiques (sans authentification)
    Route::post('/register', [AuthController::class, 'register'])->name('register');
    Route::post('/login', [AuthController::class, 'login'])->name('login');
    
    // Routes protégées (avec authentification)
    Route::middleware(['auth:sanctum'])->group(function () {
        Route::get('/me', [AuthController::class, 'me'])->name('me');
        Route::post('/logout', [AuthController::class, 'logout'])->name('logout');
        Route::post('/logout-all', [AuthController::class, 'logoutAll'])->name('logout-all');
        Route::post('/refresh', [AuthController::class, 'refresh'])->name('refresh');
        Route::get('/verify', [AuthController::class, 'verify'])->name('verify');
    });
});