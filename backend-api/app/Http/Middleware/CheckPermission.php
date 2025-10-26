<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\Log;

/**
 * Middleware de vérification des permissions
 * Système RBAC pour la plateforme VBG
 */
class CheckPermission
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, string ...$permissions): Response
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
                'permissions_required' => $permissions
            ]);

            return $this->forbiddenResponse('Compte désactivé');
        }

        // Charger le rôle et les permissions si pas encore chargé
        if (!$user->relationLoaded('role') || !$user->role->relationLoaded('permissions')) {
            $user->load(['role', 'role.permissions']);
        }

        // Vérifier si le rôle existe et est actif
        if (!$user->role || !$user->role->is_active) {
            Log::warning('Tentative d\'accès avec rôle inactif ou inexistant', [
                'user_id' => $user->id,
                'role_id' => $user->role_id,
                'ip' => $request->ip(),
                'route' => $request->route()?->getName(),
                'permissions_required' => $permissions
            ]);

            return $this->forbiddenResponse('Rôle invalide ou inactif');
        }

        // Si aucune permission spécifiée, on passe (authentification seule)
        if (empty($permissions)) {
            return $next($request);
        }

        // Vérifier les permissions
        $hasPermission = $this->checkUserPermissions($user, $permissions);

        if (!$hasPermission) {
            Log::warning('Tentative d\'accès sans permission', [
                'user_id' => $user->id,
                'role' => $user->role->name,
                'user_permissions' => $user->role->permissions->pluck('name')->toArray(),
                'required_permissions' => $permissions,
                'ip' => $request->ip(),
                'route' => $request->route()?->getName(),
                'url' => $request->fullUrl(),
            ]);

            return $this->forbiddenResponse(
                'Permissions insuffisantes. Permissions requises: ' . implode(', ', $permissions)
            );
        }

        // Log d'accès réussi pour les actions sensibles
        if ($this->isSensitiveAction($permissions)) {
            Log::info('Accès autorisé à action sensible', [
                'user_id' => $user->id,
                'role' => $user->role->name,
                'permissions_used' => $permissions,
                'ip' => $request->ip(),
                'route' => $request->route()?->getName(),
                'url' => $request->fullUrl(),
            ]);
        }

        return $next($request);
    }

    /**
     * Vérifier si l'utilisateur a les permissions requises
     */
    private function checkUserPermissions($user, array $permissions): bool
    {
        // Admin a toutes les permissions
        if ($user->role->name === 'admin') {
            return true;
        }

        // Vérifier chaque permission requise
        foreach ($permissions as $permission) {
            if (!$user->hasPermission($permission)) {
                return false;
            }
        }

        return true;
    }

    /**
     * Déterminer si l'action est sensible (nécessite logging renforcé)
     */
    private function isSensitiveAction(array $permissions): bool
    {
        $sensitivePermissions = [
            'cas.supprimer',
            'utilisateurs.supprimer',
            'utilisateurs.gerer_roles',
            'admin.parametres',
            'admin.logs',
            'rapports.exporter',
        ];

        return !empty(array_intersect($permissions, $sensitivePermissions));
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
     * Réponse pour permissions insuffisantes
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