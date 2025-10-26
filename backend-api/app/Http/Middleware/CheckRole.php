<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\Log;

/**
 * Middleware de vérification des rôles
 * Contrôle d'accès basé sur les rôles pour la plateforme VBG
 */
class CheckRole
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        // Vérifier si l'utilisateur est authentifié
        if (!$request->user()) {
            return $this->unauthorizedResponse('Authentification requise');
        }

        $user = $request->user();

        // Vérifier si l'utilisateur est actif
        if (!$user->is_active) {
            Log::warning('Tentative d\'accès avec compte inactif', [
                'user_id' => $user->id,
                'ip' => $request->ip(),
                'route' => $request->route()?->getName(),
                'roles_required' => $roles
            ]);

            return $this->forbiddenResponse('Compte désactivé');
        }

        // Charger le rôle si pas encore chargé
        if (!$user->relationLoaded('role')) {
            $user->load('role');
        }

        // Vérifier si le rôle existe et est actif
        if (!$user->role || !$user->role->is_active) {
            Log::warning('Tentative d\'accès avec rôle inactif ou inexistant', [
                'user_id' => $user->id,
                'role_id' => $user->role_id,
                'ip' => $request->ip(),
                'route' => $request->route()?->getName(),
                'roles_required' => $roles
            ]);

            return $this->forbiddenResponse('Rôle invalide ou inactif');
        }

        // Si aucun rôle spécifié, on passe (authentification seule)
        if (empty($roles)) {
            return $next($request);
        }

        // Vérifier si l'utilisateur a un des rôles requis
        $hasRole = $this->checkUserRole($user, $roles);

        if (!$hasRole) {
            Log::warning('Tentative d\'accès sans rôle approprié', [
                'user_id' => $user->id,
                'user_role' => $user->role->name,
                'required_roles' => $roles,
                'ip' => $request->ip(),
                'route' => $request->route()?->getName(),
                'url' => $request->fullUrl(),
            ]);

            return $this->forbiddenResponse(
                'Rôle insuffisant. Rôles autorisés: ' . implode(', ', $roles)
            );
        }

        // Log d'accès réussi pour les rôles administratifs
        if ($this->isAdministrativeRole($user->role->name)) {
            Log::info('Accès autorisé avec rôle administratif', [
                'user_id' => $user->id,
                'role' => $user->role->name,
                'ip' => $request->ip(),
                'route' => $request->route()?->getName(),
                'url' => $request->fullUrl(),
            ]);
        }

        return $next($request);
    }

    /**
     * Vérifier si l'utilisateur a un des rôles requis
     */
    private function checkUserRole($user, array $roles): bool
    {
        return in_array($user->role->name, $roles);
    }

    /**
     * Déterminer si le rôle est administratif (nécessite logging renforcé)
     */
    private function isAdministrativeRole(string $role): bool
    {
        return in_array($role, ['admin', 'superviseur']);
    }

    /**
     * Réponse pour utilisateur non authentifié
     */
    private function unauthorizedResponse(string $message): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => $message,
            'error_code' => 'UNAUTHORIZED'
        ], 401);
    }

    /**
     * Réponse pour rôle insuffisant
     */
    private function forbiddenResponse(string $message): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => $message,
            'error_code' => 'FORBIDDEN'
        ], 403);
    }
}