<?php

namespace App\Http\Controllers\Api\Admin;
use App\Models\Role;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserManagementController
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user || !$user->isAdmin()) {
            return new JsonResponse(['success' => false, 'message' => 'Forbidden'], 403);
        }

        $inactive = filter_var($request->query('inactive', '0'), FILTER_VALIDATE_BOOL);
        $query = User::with(['role'])
            ->when($inactive, fn($q) => $q->where('is_active', false));

        $perPage = (int) $request->query('per_page', 15);
        $users = $query->paginate($perPage);

        // Map minimal safe payload
        $data = collect($users->items())->map(function ($u) {
            return [
                'id' => $u->id,
                'email' => $u->email,
                'phone' => $u->phone,
                'role' => $u->role?->name,
                'role_display_name' => $u->role?->display_name,
                'is_active' => (bool) $u->is_active,
                'created_at' => optional($u->created_at)->toISOString(),
                'last_login_at' => optional($u->last_login_at)->toISOString(),
            ];
        })->values();

        return new JsonResponse([
            'success' => true,
            'data' => [
                'users' => $data,
                'meta' => [
                    'total' => $users->total(),
                    'per_page' => $users->perPage(),
                    'current_page' => $users->currentPage(),
                    'last_page' => $users->lastPage(),
                ]
            ]
        ]);
    }

    public function update($id, Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user || !$user->isAdmin()) {
            return new JsonResponse(['success' => false, 'message' => 'Forbidden'], 403);
        }

        $target = User::findOrFail($id);

        $validated = $request->validate([
            'role_id' => 'sometimes|uuid|exists:roles,id',
            'is_active' => 'sometimes|boolean',
        ]);

        if (array_key_exists('role_id', $validated)) {
            $target->role_id = $validated['role_id'];
        }
        if (array_key_exists('is_active', $validated)) {
            $target->is_active = $validated['is_active'];
        }
        $target->save();

        return new JsonResponse(['success' => true, 'message' => 'Utilisateur mis à jour']);
    }
}
