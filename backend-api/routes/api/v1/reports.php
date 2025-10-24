<?php

use Illuminate\Support\Facades\Route;
use App\Interface\Http\Controllers\API\V1\Reports\ReportController;
use App\Interface\Http\Controllers\API\V1\Reports\ReportStatusController;

/*
|--------------------------------------------------------------------------
| Reports API Routes
|--------------------------------------------------------------------------
|
| Routes pour la gestion des signalements VBG
| Organisées selon les principes DDD pour le domaine Reports
|
*/

Route::prefix('reports')->name('reports.')->middleware(['auth:sanctum'])->group(function () {
    
    // CRUD des signalements
    Route::get('/', [ReportController::class, 'index'])->name('index');
    Route::post('/', [ReportController::class, 'store'])->name('store');
    Route::get('/{report}', [ReportController::class, 'show'])->name('show');
    Route::put('/{report}', [ReportController::class, 'update'])->name('update');
    Route::delete('/{report}', [ReportController::class, 'destroy'])->name('destroy');
    
    // Gestion des statuts de signalement
    Route::put('/{report}/status', [ReportStatusController::class, 'updateStatus'])->name('update-status');
    Route::get('/{report}/history', [ReportStatusController::class, 'statusHistory'])->name('status-history');
    
    // Recherche et filtres
    Route::get('/search', [ReportController::class, 'search'])->name('search');
    Route::get('/filter', [ReportController::class, 'filter'])->name('filter');
    
    // Statistiques (pour les administrateurs)
    Route::middleware(['role:admin'])->prefix('admin')->name('admin.')->group(function () {
        Route::get('/statistics', [ReportController::class, 'statistics'])->name('statistics');
        Route::get('/analytics', [ReportController::class, 'analytics'])->name('analytics');
        Route::get('/export', [ReportController::class, 'export'])->name('export');
    });
    
    // Mes signalements (pour les utilisateurs)
    Route::get('/my-reports', [ReportController::class, 'myReports'])->name('my-reports');
    Route::get('/my-reports/statistics', [ReportController::class, 'myReportsStatistics'])->name('my-reports-statistics');
});