<?php

use Illuminate\Support\Facades\Route;
use App\Interface\Http\Controllers\API\V1\Auth\AuthController;
use App\Interface\Http\Controllers\API\V1\Auth\PasswordController;

/*
|--------------------------------------------------------------------------
| Auth API Routes
|--------------------------------------------------------------------------
|
| Routes pour l'authentification et la gestion des utilisateurs
| Organisées selon les principes DDD pour le domaine Auth
|
*/

Route::prefix('auth')->name('auth.')->group(function () {
    
    // Routes publiques (sans authentification)
    Route::post('/register', [AuthController::class, 'register'])->name('register');
    Route::post('/login', [AuthController::class, 'login'])->name('login');
    Route::post('/forgot-password', [PasswordController::class, 'forgotPassword'])->name('forgot-password');
    Route::post('/reset-password', [PasswordController::class, 'resetPassword'])->name('reset-password');
    Route::post('/verify-email', [AuthController::class, 'verifyEmail'])->name('verify-email');
    Route::post('/resend-verification', [AuthController::class, 'resendVerification'])->name('resend-verification');
    
    // Routes protégées (avec authentification)
    Route::middleware(['auth:sanctum'])->group(function () {
        Route::get('/me', [AuthController::class, 'me'])->name('me');
        Route::put('/profile', [AuthController::class, 'updateProfile'])->name('update-profile');
        Route::post('/logout', [AuthController::class, 'logout'])->name('logout');
        Route::post('/refresh', [AuthController::class, 'refresh'])->name('refresh');
        Route::delete('/delete-account', [AuthController::class, 'deleteAccount'])->name('delete-account');
    });
    
    // Routes pour les administrateurs
    Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->name('admin.')->group(function () {
        Route::get('/users', [AuthController::class, 'listUsers'])->name('list-users');
        Route::put('/users/{user}/activate', [AuthController::class, 'activateUser'])->name('activate-user');
        Route::put('/users/{user}/deactivate', [AuthController::class, 'deactivateUser'])->name('deactivate-user');
        Route::delete('/users/{user}', [AuthController::class, 'deleteUser'])->name('delete-user');
    });
});