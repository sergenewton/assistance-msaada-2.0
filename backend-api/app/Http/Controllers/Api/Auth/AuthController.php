<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Models\User;
use App\Models\Role;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\RateLimiter;
use Laravel\Sanctum\PersonalAccessToken;

/**
 * Controller d'authentification pour l'API
 * Gestion JWT avec sécurité renforcée pour plateforme VBG
 */
class AuthController extends Controller
{
    /**
     * Inscription d'un nouvel utilisateur
     * 
     * @param RegisterRequest $request
     * @return JsonResponse
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        try {
            $validated = $request->validated();
            
            // Obtenir le rôle (par défaut survivante)
            $role = Role::where('name', $validated['role'] ?? 'survivante')->first();
            
            if (!$role) {
                return response()->json([
                    'success' => false,
                    'message' => 'Rôle invalide'
                ], 400);
            }
            
            // Créer l'utilisateur
            $user = User::create([
                'email' => $validated['email'] ?? null,
                'phone' => $validated['phone'] ?? null, 
                'password' => $validated['password'],
                'role_id' => $role->id,
                'organization_id' => $validated['organization_id'] ?? null,
                'is_active' => true,
            ]);

            // Générer le token
            $token = $user->createToken(
                'auth_token',
                ['*'],
                now()->addMinutes(config('sanctum.expiration', 60))
            );

            // Log de sécurité
            Log::info('Nouvelle inscription utilisateur', [
                'user_id' => $user->id,
                'role' => $role->name,
                'ip' => $request->ip(),
                'user_agent' => $request->userAgent(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Inscription réussie',
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'role' => $role->name,
                        'role_display_name' => $role->display_name,
                        'permissions' => $role->permissions()->pluck('name')->toArray(),
                        'organization_id' => $user->organization_id,
                        'is_active' => $user->is_active,
                        'created_at' => $user->created_at,
                    ],
                    'token' => [
                        'access_token' => $token->plainTextToken,
                        'token_type' => 'Bearer',
                        'expires_at' => $token->accessToken->expires_at,
                    ]
                ]
            ], 201);

        } catch (\Exception $e) {
            Log::error('Erreur lors de l\'inscription', [
                'error' => $e->getMessage(),
                'ip' => $request->ip(),
                'data' => $request->except('password')
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'inscription'
            ], 500);
        }
    }

    /**
     * Connexion d'un utilisateur
     * 
     * @param LoginRequest $request
     * @return JsonResponse
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $validated = $request->validated();
        $identifier = $validated['identifier']; // Email ou téléphone
        $password = $validated['password'];
        $rememberMe = $validated['remember_me'] ?? false;

        // Rate limiting - 5 tentatives par minute par IP
        $key = 'login.' . $request->ip();
        if (RateLimiter::tooManyAttempts($key, 5)) {
            $seconds = RateLimiter::availableIn($key);
            
            Log::warning('Trop de tentatives de connexion', [
                'ip' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'identifier' => $identifier,
                'retry_after' => $seconds
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Trop de tentatives. Réessayez dans ' . $seconds . ' secondes.'
            ], 429);
        }

        try {
            // Chercher l'utilisateur par email ou téléphone
            $user = User::with(['role', 'role.permissions'])
                ->where(function ($query) use ($identifier) {
                    // Note: Pour les champs chiffrés, on devrait implémenter une recherche spéciale
                    // Pour l'instant, on assume qu'on peut chercher directement
                    $query->where('email', $identifier)
                          ->orWhere('phone', $identifier);
                })
                ->where('is_active', true)
                ->first();

            if (!$user || !Hash::check($password, $user->password)) {
                RateLimiter::hit($key);
                
                Log::warning('Tentative de connexion échouée', [
                    'identifier' => $identifier,
                    'ip' => $request->ip(),
                    'user_agent' => $request->userAgent(),
                ]);

                throw ValidationException::withMessages([
                    'identifier' => ['Identifiants incorrects']
                ]);
            }

            // Vérifier si le compte est actif
            if (!$user->is_active) {
                Log::warning('Tentative de connexion sur compte inactif', [
                    'user_id' => $user->id,
                    'ip' => $request->ip(),
                ]);

                return response()->json([
                    'success' => false,
                    'message' => 'Compte désactivé. Contactez l\'administrateur.'
                ], 403);
            }

            // Révoquer les anciens tokens (session unique)
            $user->tokens()->delete();

            // Générer un nouveau token
            $tokenExpiration = $rememberMe 
                ? now()->addDays(7) 
                : now()->addMinutes(config('sanctum.expiration', 60));

            $token = $user->createToken(
                'auth_token',
                ['*'],
                $tokenExpiration
            );

            // Mettre à jour les informations de connexion
            $user->update([
                'last_login_at' => now(),
                'last_login_ip' => $request->ip(),
            ]);

            // Clear rate limiting
            RateLimiter::clear($key);

            // Log de sécurité
            Log::info('Connexion réussie', [
                'user_id' => $user->id,
                'role' => $user->role->name,
                'ip' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'remember_me' => $rememberMe,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Connexion réussie',
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'email' => $user->email,
                        'phone' => $user->phone,
                        'role' => $user->role->name,
                        'role_display_name' => $user->role->display_name,
                        'permissions' => $user->role->permissions->pluck('name')->toArray(),
                        'organization_id' => $user->organization_id,
                        'two_factor_enabled' => $user->two_factor_enabled,
                        'last_login_at' => $user->last_login_at,
                    ],
                    'token' => [
                        'access_token' => $token->plainTextToken,
                        'token_type' => 'Bearer',
                        'expires_at' => $token->accessToken->expires_at,
                    ]
                ]
            ]);

        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Identifiants incorrects',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            Log::error('Erreur lors de la connexion', [
                'error' => $e->getMessage(),
                'ip' => $request->ip(),
                'identifier' => $identifier
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la connexion'
            ], 500);
        }
    }

    /**
     * Déconnexion de l'utilisateur
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function logout(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            
            // Révoquer le token actuel
            $request->user()->currentAccessToken()->delete();

            // Log de sécurité
            Log::info('Déconnexion utilisateur', [
                'user_id' => $user->id,
                'ip' => $request->ip(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Déconnexion réussie'
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur lors de la déconnexion', [
                'error' => $e->getMessage(),
                'user_id' => $request->user()?->id,
                'ip' => $request->ip(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la déconnexion'
            ], 500);
        }
    }

    /**
     * Déconnexion de tous les appareils
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function logoutAll(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            
            // Révoquer tous les tokens
            $user->tokens()->delete();

            // Log de sécurité
            Log::info('Déconnexion de tous les appareils', [
                'user_id' => $user->id,
                'ip' => $request->ip(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Déconnexion de tous les appareils réussie'
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur lors de la déconnexion globale', [
                'error' => $e->getMessage(),
                'user_id' => $request->user()?->id,
                'ip' => $request->ip(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la déconnexion'
            ], 500);
        }
    }

    /**
     * Rafraîchir le token d'accès
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function refresh(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            $currentToken = $request->user()->currentAccessToken();

            // Révoquer le token actuel
            $currentToken->delete();

            // Générer un nouveau token
            $token = $user->createToken(
                'auth_token',
                ['*'],
                now()->addMinutes(config('sanctum.expiration', 60))
            );

            // Log de sécurité
            Log::info('Token rafraîchi', [
                'user_id' => $user->id,
                'ip' => $request->ip(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Token rafraîchi',
                'data' => [
                    'token' => [
                        'access_token' => $token->plainTextToken,
                        'token_type' => 'Bearer',
                        'expires_at' => $token->accessToken->expires_at,
                    ]
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur lors du rafraîchissement du token', [
                'error' => $e->getMessage(),
                'user_id' => $request->user()?->id,
                'ip' => $request->ip(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du rafraîchissement'
            ], 500);
        }
    }

    /**
     * Obtenir les informations de l'utilisateur connecté
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function me(Request $request): JsonResponse
    {
        try {
            $user = $request->user()->load(['role', 'role.permissions', 'organization']);

            return response()->json([
                'success' => true,
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'email' => $user->email,
                        'phone' => $user->phone,
                        'role' => $user->role->name,
                        'role_display_name' => $user->role->display_name,
                        'permissions' => $user->role->permissions->pluck('name')->toArray(),
                        'organization' => $user->organization ? [
                            'id' => $user->organization->id,
                            'name' => $user->organization->name,
                            'type' => $user->organization->type,
                        ] : null,
                        'two_factor_enabled' => $user->two_factor_enabled,
                        'last_login_at' => $user->last_login_at,
                        'created_at' => $user->created_at,
                    ]
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Erreur lors de la récupération du profil', [
                'error' => $e->getMessage(),
                'user_id' => $request->user()?->id,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération du profil'
            ], 500);
        }
    }

    /**
     * Vérifier la validité du token
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function verify(Request $request): JsonResponse
    {
        $token = $request->user()->currentAccessToken();
        
        return response()->json([
            'success' => true,
            'data' => [
                'valid' => true,
                'expires_at' => $token->expires_at,
                'user_id' => $request->user()->id,
            ]
        ]);
    }
}