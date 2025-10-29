<?php

use Illuminate\Support\Facades\Route;
use App\Interface\Http\Controllers\API\V1\Reports\PublicReportController;

/*
|--------------------------------------------------------------------------
| Public API Routes (no auth)
|--------------------------------------------------------------------------
*/

Route::prefix('reports')->group(function () {
    Route::post('/submit', [PublicReportController::class, 'submit'])->name('public.reports.submit');
    Route::get('/{tracking}', [PublicReportController::class, 'showByTracking'])
        ->where('tracking', 'VBG-\\d{4}-\\d{4}')
        ->name('public.reports.show');
});
