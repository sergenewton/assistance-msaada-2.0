<?php

use App\Http\Controllers\Api\Admin\RoleManagementController;
use App\Http\Controllers\Api\Admin\UserManagementController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Admin API Routes
|--------------------------------------------------------------------------
| Routes protégées pour les administrateurs
*/

Route::middleware(['auth:sanctum', 'admin'])->group(function () {
    
    // User Management
    Route::prefix('users')->group(function () {
        Route::get('/', [UserManagementController::class, 'index']);
        Route::get('/{id}', [UserManagementController::class, 'show']);
        Route::post('/', [UserManagementController::class, 'store']);
        Route::put('/{id}', [UserManagementController::class, 'update']);
        Route::delete('/{id}', [UserManagementController::class, 'destroy']);
        Route::post('/{id}/restore', [UserManagementController::class, 'restore']);
        Route::post('/{id}/toggle-active', [UserManagementController::class, 'toggleActive']);
    });

    // Role Management
    Route::prefix('roles')->group(function () {
        Route::get('/', [RoleManagementController::class, 'index']);
        Route::get('/{id}', [RoleManagementController::class, 'show']);
        Route::post('/', [RoleManagementController::class, 'store']);
        Route::put('/{id}', [RoleManagementController::class, 'update']);
        Route::delete('/{id}', [RoleManagementController::class, 'destroy']);
    });
});
