<?php

namespace App\Interface\Http\Controllers\API\V1\Reports;

use Illuminate\Routing\Controller as Controller;
use App\Models\Report;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    /**
     * GET /api/v1/reports
     * Liste paginée des signalements avec filtres simples.
     */
    public function index(Request $request)
    {
        $query = Report::query();

        // Filtres
        if ($status = $request->string('status')->toString()) {
            if (method_exists(Report::class, 'scopeByStatus')) {
                $query->byStatus($status);
            } else {
                $query->where('status', $status);
            }
        }

        $urgency = $request->string('urgency')->toString();
        if (!empty($urgency)) {
            $levels = collect(explode(',', $urgency))->map(fn($v) => trim($v))->filter();
            $query->whereIn('urgency_level', $levels->all());
        }

        // Triage: non assignés si demandé
        if ($request->boolean('unassigned')) {
            if (method_exists(Report::class, 'scopeUnassigned')) {
                $query->unassigned();
            } else {
                $query->whereNull('assigned_aps_id');
            }
        }

        // Tri
        $sort = $request->string('sort')->toString();
        if ($sort) {
            $direction = str_starts_with($sort, '-') ? 'desc' : 'asc';
            $column = ltrim($sort, '-');
            $query->orderBy($column, $direction);
        } else {
            $query->orderBy('created_at', 'desc');
        }

        $perPage = (int) $request->integer('limit', 25);
        $reports = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'message' => 'Reports list',
            'data' => [
                'items' => $reports->items(),
                'pagination' => [
                    'total' => $reports->total(),
                    'per_page' => $reports->perPage(),
                    'current_page' => $reports->currentPage(),
                    'last_page' => $reports->lastPage(),
                ],
            ],
        ]);
    }

    /**
     * GET /api/v1/reports/filter
     * Alias de index pour compatibilité.
     */
    public function filter(Request $request)
    {
        return $this->index($request);
    }

    /**
     * GET /api/v1/reports/unprocessed
     * Signale les cas non traités (nouveaux et non assignés).
     */
    public function unprocessed(Request $request)
    {
        $query = Report::query();

        // Non traités = statut 'new' et non assignés (si le scope existe)
        if (method_exists(Report::class, 'scopeUnassigned')) {
            $query->unassigned();
        } else {
            $query->whereNull('assigned_aps_id')->where('status', 'new');
        }

        $query->orderBy('created_at', 'desc');
        $perPage = (int) $request->integer('limit', 25);
        $reports = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'message' => 'Unprocessed reports',
            'data' => [
                'items' => $reports->items(),
                'pagination' => [
                    'total' => $reports->total(),
                    'per_page' => $reports->perPage(),
                    'current_page' => $reports->currentPage(),
                    'last_page' => $reports->lastPage(),
                ],
            ],
        ]);
    }

    /**
     * GET /api/v1/reports/unprocessed-urgent
     * Cas non traités ET urgents (high|critical).
     */
    public function unprocessedUrgent(Request $request)
    {
        $query = Report::query();

        // Non traités (new + non assignés)
        if (method_exists(Report::class, 'scopeUnassigned')) {
            $query->unassigned();
        } else {
            $query->whereNull('assigned_aps_id')->where('status', 'new');
        }

        // Urgents
        if (method_exists(Report::class, 'scopeUrgent')) {
            $query->urgent();
        } else {
            $query->whereIn('urgency_level', ['high', 'critical']);
        }

        $query->orderBy('created_at', 'desc');
        $perPage = (int) $request->integer('limit', 25);
        $reports = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'message' => 'Unprocessed urgent reports',
            'data' => [
                'items' => $reports->items(),
                'pagination' => [
                    'total' => $reports->total(),
                    'per_page' => $reports->perPage(),
                    'current_page' => $reports->currentPage(),
                    'last_page' => $reports->lastPage(),
                ],
            ],
        ]);
    }
}
