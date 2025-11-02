<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Role;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class RoleManagementController extends Controller
{
    /**
     * Liste tous les rôles
     */
    public function index(): JsonResponse
    {
        $roles = Role::where('is_active', true)
            ->orderBy('name')
            ->get();

        $rolesData = $roles->map(function ($role) {
            return [
                'id' => $role->id,
                'name' => $role->name,
                'display_name' => $role->display_name,
                'description' => $role->description,
                'permissions' => $role->permissions ? json_decode($role->permissions, true) : [],
                'is_active' => $role->is_active,
                'created_at' => $role->created_at->toISOString(),
                'updated_at' => $role->updated_at->toISOString(),
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $rolesData,
        ]);
    }

    /**
     * Affiche un rôle spécifique
     */
    public function show(string $id): JsonResponse
    {
        $role = Role::find($id);

        if (!$role) {
            return response()->json([
                'success' => false,
                'message' => 'Rôle non trouvé',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $role->id,
                'name' => $role->name,
                'display_name' => $role->display_name,
                'description' => $role->description,
                'permissions' => $role->permissions ? json_decode($role->permissions, true) : [],
                'is_active' => $role->is_active,
                'created_at' => $role->created_at->toISOString(),
                'updated_at' => $role->updated_at->toISOString(),
            ],
        ]);
    }

    /**
     * Crée un nouveau rôle
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|unique:roles,name|max:50',
            'display_name' => 'required|string|max:100',
            'description' => 'nullable|string',
            'permissions' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation échouée',
                'errors' => $validator->errors(),
            ], 422);
        }

        $role = Role::create([
            'name' => $request->input('name'),
            'display_name' => $request->input('display_name'),
            'description' => $request->input('description'),
            'permissions' => $request->input('permissions') ? json_encode($request->input('permissions')) : null,
            'is_active' => true,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Rôle créé avec succès',
            'data' => [
                'id' => $role->id,
                'name' => $role->name,
                'display_name' => $role->display_name,
            ],
        ], 201);
    }

    /**
     * Met à jour un rôle
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $role = Role::find($id);

        if (!$role) {
            return response()->json([
                'success' => false,
                'message' => 'Rôle non trouvé',
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'string|unique:roles,name,' . $id . '|max:50',
            'display_name' => 'string|max:100',
            'description' => 'nullable|string',
            'permissions' => 'nullable|array',
            'is_active' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation échouée',
                'errors' => $validator->errors(),
            ], 422);
        }

        if ($request->has('name')) {
            $role->name = $request->input('name');
        }
        if ($request->has('display_name')) {
            $role->display_name = $request->input('display_name');
        }
        if ($request->has('description')) {
            $role->description = $request->input('description');
        }
        if ($request->has('permissions')) {
            $role->permissions = $request->input('permissions') ? json_encode($request->input('permissions')) : null;
        }
        if ($request->has('is_active')) {
            $role->is_active = $request->input('is_active');
        }

        $role->save();

        return response()->json([
            'success' => true,
            'message' => 'Rôle mis à jour avec succès',
            'data' => [
                'id' => $role->id,
                'name' => $role->name,
                'display_name' => $role->display_name,
            ],
        ]);
    }

    /**
     * Supprime un rôle
     */
    public function destroy(string $id): JsonResponse
    {
        $role = Role::find($id);

        if (!$role) {
            return response()->json([
                'success' => false,
                'message' => 'Rôle non trouvé',
            ], 404);
        }

        // Vérifier qu'aucun utilisateur n'utilise ce rôle
        $usersCount = $role->users()->count();
        if ($usersCount > 0) {
            return response()->json([
                'success' => false,
                'message' => "Impossible de supprimer ce rôle car {$usersCount} utilisateur(s) l'utilisent encore",
            ], 400);
        }

        $role->delete();

        return response()->json([
            'success' => true,
            'message' => 'Rôle supprimé avec succès',
        ]);
    }
}
