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

    // CRUD des signalements (certains endpoints peuvent ne pas être encore implémentés)
    Route::get('/', [ReportController::class, 'index'])->name('index');
    // Route::post('/', [ReportController::class, 'store'])->name('store');
    // Route::get('/{report}', [ReportController::class, 'show'])->name('show');
    // Route::put('/{report}', [ReportController::class, 'update'])->name('update');
    // Route::delete('/{report}', [ReportController::class, 'destroy'])->name('destroy');

    // Endpoints triage opérateur
    Route::get('/unprocessed', [ReportController::class, 'unprocessed'])->name('unprocessed');
    Route::get('/unprocessed-urgent', [ReportController::class, 'unprocessedUrgent'])->name('unprocessed-urgent');

    // Recherche et filtres
    Route::get('/filter', [ReportController::class, 'filter'])->name('filter');

    // Gestion des statuts (peuvent être implémentés plus tard)
    // Route::put('/{report}/status', [ReportStatusController::class, 'updateStatus'])->name('update-status');
    // Route::get('/{report}/history', [ReportStatusController::class, 'statusHistory'])->name('status-history');

    // Statistiques (pour les administrateurs)
    // Route::middleware(['role:admin'])->prefix('admin')->name('admin.')->group(function () {
    //     Route::get('/statistics', [ReportController::class, 'statistics'])->name('statistics');
    //     Route::get('/analytics', [ReportController::class, 'analytics'])->name('analytics');
    //     Route::get('/export', [ReportController::class, 'export'])->name('export');
    // });

    // Mes signalements (pour les utilisateurs)
    // Route::get('/my-reports', [ReportController::class, 'myReports'])->name('my-reports');
    // Route::get('/my-reports/statistics', [ReportController::class, 'myReportsStatistics'])->name('my-reports-statistics');
});