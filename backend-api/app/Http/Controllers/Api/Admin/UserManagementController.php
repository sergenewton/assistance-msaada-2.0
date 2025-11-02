<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class UserManagementController extends Controller
{
    /**
     * Liste tous les utilisateurs avec pagination et filtres
     */
    public function index(Request $request): JsonResponse
    {
        $query = User::with(['role', 'organization']);

        // Filtre par recherche (nom, email)
        if ($request->has('search')) {
            $search = $request->input('search');
            $query->where(function ($q) use ($search) {
                // Note: email est chiffré, donc la recherche sera limitée
                // On peut chercher par ID ou d'autres champs non-chiffrés
                $q->where('id', 'like', "%{$search}%");
            });
        }

        // Filtre par statut
        if ($request->has('status')) {
            $status = $request->input('status');
            if ($status === 'active') {
                $query->where('is_active', true);
            } elseif ($status === 'inactive') {
                $query->where('is_active', false);
            }
        }

        // Filtre par rôle
        if ($request->has('role_id')) {
            $query->where('role_id', $request->input('role_id'));
        }

        // Tri
        $sortBy = $request->input('sort_by', 'created_at');
        $sortOrder = $request->input('sort_order', 'desc');
        $query->orderBy($sortBy, $sortOrder);

        // Pagination
        $perPage = $request->input('per_page', 15);
        $users = $query->paginate($perPage);

        // Formater les données pour le frontend
        $users->getCollection()->transform(function ($user) {
            return [
                'id' => $user->id,
                'email' => $user->email,
                'phone' => $user->phone,
                'role' => $user->role ? $user->role->name : null,
                'role_display_name' => $user->role ? $user->role->display_name : null,
                'organization_id' => $user->organization_id,
                'organization_name' => $user->organization ? $user->organization->name : null,
                'is_active' => $user->is_active,
                'two_factor_enabled' => $user->two_factor_enabled,
                'last_login_at' => $user->last_login_at?->toISOString(),
                'created_at' => $user->created_at->toISOString(),
                'updated_at' => $user->updated_at->toISOString(),
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $users,
        ]);
    }

    /**
     * Affiche un utilisateur spécifique
     */
    public function show(string $id): JsonResponse
    {
        $user = User::with(['role', 'organization'])->find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Utilisateur non trouvé',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $user->id,
                'email' => $user->email,
                'phone' => $user->phone,
                'role' => $user->role ? $user->role->name : null,
                'role_display_name' => $user->role ? $user->role->display_name : null,
                'organization_id' => $user->organization_id,
                'organization_name' => $user->organization ? $user->organization->name : null,
                'is_active' => $user->is_active,
                'two_factor_enabled' => $user->two_factor_enabled,
                'last_login_at' => $user->last_login_at?->toISOString(),
                'created_at' => $user->created_at->toISOString(),
                'updated_at' => $user->updated_at->toISOString(),
            ],
        ]);
    }

    /**
     * Crée un nouvel utilisateur
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|unique:users,email',
            'phone' => 'nullable|string',
            'password' => 'required|string|min:8',
            'role_id' => 'required|exists:roles,id',
            'organization_id' => 'nullable|exists:organizations,id',
            'is_active' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation échouée',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = User::create([
            'email' => $request->input('email'),
            'phone' => $request->input('phone'),
            'password' => Hash::make($request->input('password')),
            'role_id' => $request->input('role_id'),
            'organization_id' => $request->input('organization_id'),
            'is_active' => $request->input('is_active', true),
            'two_factor_enabled' => false,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Utilisateur créé avec succès',
            'data' => [
                'id' => $user->id,
                'email' => $user->email,
                'role' => $user->role ? $user->role->name : null,
            ],
        ], 201);
    }

    /**
     * Met à jour un utilisateur
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Utilisateur non trouvé',
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'email' => 'email|unique:users,email,' . $id,
            'phone' => 'nullable|string',
            'password' => 'nullable|string|min:8',
            'role_id' => 'exists:roles,id',
            'organization_id' => 'nullable|exists:organizations,id',
            'is_active' => 'boolean',
            'two_factor_enabled' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation échouée',
                'errors' => $validator->errors(),
            ], 422);
        }

        // Mise à jour des champs
        if ($request->has('email')) {
            $user->email = $request->input('email');
        }
        if ($request->has('phone')) {
            $user->phone = $request->input('phone');
        }
        if ($request->has('password')) {
            $user->password = Hash::make($request->input('password'));
        }
        if ($request->has('role_id')) {
            $user->role_id = $request->input('role_id');
        }
        if ($request->has('organization_id')) {
            $user->organization_id = $request->input('organization_id');
        }
        if ($request->has('is_active')) {
            $user->is_active = $request->input('is_active');
        }
        if ($request->has('two_factor_enabled')) {
            $user->two_factor_enabled = $request->input('two_factor_enabled');
        }

        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Utilisateur mis à jour avec succès',
            'data' => [
                'id' => $user->id,
                'email' => $user->email,
                'is_active' => $user->is_active,
            ],
        ]);
    }

    /**
     * Supprime (soft delete) un utilisateur
     */
    public function destroy(string $id): JsonResponse
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Utilisateur non trouvé',
            ], 404);
        }

        // Ne pas permettre la suppression de son propre compte
        if (auth()->id() === $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Vous ne pouvez pas supprimer votre propre compte',
            ], 403);
        }

        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'Utilisateur supprimé avec succès',
        ]);
    }

    /**
     * Restaure un utilisateur supprimé
     */
    public function restore(string $id): JsonResponse
    {
        $user = User::withTrashed()->find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Utilisateur non trouvé',
            ], 404);
        }

        if (!$user->trashed()) {
            return response()->json([
                'success' => false,
                'message' => 'L\'utilisateur n\'est pas supprimé',
            ], 400);
        }

        $user->restore();

        return response()->json([
            'success' => true,
            'message' => 'Utilisateur restauré avec succès',
        ]);
    }

    /**
     * Active/désactive un utilisateur
     */
    public function toggleActive(string $id): JsonResponse
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Utilisateur non trouvé',
            ], 404);
        }

        $user->is_active = !$user->is_active;
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Statut utilisateur mis à jour',
            'data' => [
                'is_active' => $user->is_active,
            ],
        ]);
    }
}
