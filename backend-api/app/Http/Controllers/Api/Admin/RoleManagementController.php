<?php

namespace App\Http\Controllers\Api\Admin;

use App\Models\Permission;
use App\Models\Role;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RoleManagementController
{
    public function roles(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user || !$user->isAdmin()) {
            return new JsonResponse(['success' => false, 'message' => 'Forbidden'], 403);
        }

        $roles = Role::with('permissions')->get()->map(function ($r) {
            return [
                'id' => $r->id,
                'name' => $r->name,
                'display_name' => $r->display_name,
                'permissions' => $r->permissions ? $r->permissions->pluck('name')->values()->all() : [],
            ];
        });

        return new JsonResponse(['success' => true, 'data' => ['roles' => $roles]]);
    }

    public function permissions(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user || !$user->isAdmin()) {
            return new JsonResponse(['success' => false, 'message' => 'Forbidden'], 403);
        }

        $permissions = Permission::query()->orderBy('name')->get(['id', 'name', 'description']);
        return new JsonResponse(['success' => true, 'data' => ['permissions' => $permissions]]);
    }

    public function syncRolePermissions(Role $role, Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user || !$user->isAdmin()) {
            return new JsonResponse(['success' => false, 'message' => 'Forbidden'], 403);
        }

        $data = $request->validate([
            'permissions' => 'required|array',
            'permissions.*' => 'string|exists:permissions,name',
        ]);

        // Convert permission names to IDs
        $permissionIds = Permission::whereIn('name', $data['permissions'])->pluck('id');
        $role->permissions()->sync($permissionIds);

        return new JsonResponse(['success' => true, 'message' => 'Permissions mises à jour']);
    }
}
