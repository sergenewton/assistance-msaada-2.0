<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CheckAdminRole
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        if (!auth()->check()) {
            return response()->json([
                'success' => false,
                'message' => 'Non authentifié',
            ], 401);
        }

        $user = auth()->user();
        
        if (!$user->role || $user->role->name !== 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Accès refusé. Permissions administrateur requises.',
            ], 403);
        }

        return $next($request);
    }
}
