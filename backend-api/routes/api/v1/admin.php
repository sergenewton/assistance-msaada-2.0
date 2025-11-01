<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Admin\UserManagementController;
use App\Http\Controllers\Api\Admin\RoleManagementController;

Route::prefix('admin')->middleware(['auth:api'])->group(function () {
    // Users management
    Route::get('/users', [UserManagementController::class, 'index']);
    Route::patch('/users/{id}', [UserManagementController::class, 'update']);

    // Roles & permissions
    Route::get('/roles', [RoleManagementController::class, 'roles']);
    Route::get('/permissions', [RoleManagementController::class, 'permissions']);
    Route::post('/roles/{role}/permissions', [RoleManagementController::class, 'syncRolePermissions']);
});
