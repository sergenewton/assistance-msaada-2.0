<?php

namespace App\Http\Controllers\Api\Auth;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Illuminate\Http\JsonResponse;

class AuthController extends \Illuminate\Routing\Controller
{
	/**
	 * POST /api/v1/auth/login
	 * Accepts { identifier, password, remember_me?, device_name? }
	 */
	public function login(Request $request): JsonResponse
	{
		$request->validate([
			'identifier' => ['required', 'string'],
			'password'   => ['required', 'string'],
			'device_name'=> ['nullable', 'string'],
		]);

		$identifier = (string) $request->input('identifier');
		$password   = (string) $request->input('password');
		$deviceName = (string) ($request->input('device_name') ?: 'Web Browser');

		// IMPORTANT: email & phone are stored encrypted. We cannot directly query by plaintext.
		// As a pragmatic dev-mode fallback, scan users and compare decrypted values.
		// NOTE: For production, add searchable hashed columns (e.g., email_hash) to query efficiently.
		$candidate = User::query()->with(['role'])->get()->first(function (User $u) use ($identifier) {
			$email = $u->email; // decrypted by trait accessors
			$phone = $u->phone; // decrypted by trait accessors
			return ($email && strcasecmp($email, $identifier) === 0) || ($phone && $phone === $identifier);
		});

		if (!$candidate || !Hash::check($password, $candidate->getAuthPassword())) {
			return new JsonResponse([
				'success' => false,
				'message' => "Identifiants invalides",
			], 401);
		}

		if (property_exists($candidate, 'is_active') && !$candidate->is_active) {
			return new JsonResponse([
				'success' => false,
				'message' => "Compte inactif. Contactez l'administrateur.",
			], 403);
		}

		// Create a Sanctum personal access token
		$plainToken = $candidate->createToken($deviceName)->plainTextToken;

		// Build response payload expected by frontend
		$expiresAt = now()->addHours(8)->toIso8601String();
		$payload = [
			'success' => true,
			'message' => 'Connexion réussie',
			'data' => [
				'user' => [
					'id' => (string) $candidate->getKey(),
					'email' => $candidate->email,
					'phone' => $candidate->phone,
					'role' => optional($candidate->role)->name ?? 'user',
					'role_display_name' => optional($candidate->role)->display_name ?? 'Utilisateur',
					// Use relation method to avoid null when a JSON attribute named 'permissions' exists
					'permissions' => $candidate->role ? ($candidate->role->permissions()->pluck('name')->all() ?? []) : [],
					'organization_id' => $candidate->organization_id,
					'two_factor_enabled' => (bool) ($candidate->two_factor_enabled ?? false),
					'last_login_at' => now()->toIso8601String(),
					'created_at' => optional($candidate->created_at)->toIso8601String(),
				],
				'token' => [
					'access_token' => $plainToken,
					'token_type' => 'Bearer',
					'expires_at' => $expiresAt,
				],
			],
		];

		// Optionally update last_login_at
		if ($candidate->isFillable('last_login_at')) {
			$candidate->forceFill(['last_login_at' => now()])->saveQuietly();
		}

		return new JsonResponse($payload);
	}

	/**
	 * GET /api/v1/auth/me (auth:sanctum)
	 */
	public function me(Request $request): JsonResponse
	{
		/** @var User $user */
		$user = $request->user();
		return new JsonResponse([
			'success' => true,
			'message' => 'OK',
			'data' => [
				'user' => [
					'id' => (string) $user->getKey(),
					'email' => $user->email,
					'phone' => $user->phone,
					'role' => optional($user->role)->name ?? 'user',
					'role_display_name' => optional($user->role)->display_name ?? 'Utilisateur',
					'permissions' => $user->role ? ($user->role->permissions()->pluck('name')->all() ?? []) : [],
					'organization_id' => $user->organization_id,
					'two_factor_enabled' => (bool) ($user->two_factor_enabled ?? false),
					'last_login_at' => optional($user->last_login_at)->toIso8601String(),
					'created_at' => optional($user->created_at)->toIso8601String(),
				]
			]
		]);
	}

	/**
	 * POST /api/v1/auth/logout (auth:sanctum)
	 */
	public function logout(Request $request): JsonResponse
	{
		$request->user()?->currentAccessToken()?->delete();
		return new JsonResponse(['success' => true, 'message' => 'Déconnecté']);
	}

	/**
	 * POST /api/v1/auth/logout-all (auth:sanctum)
	 */
	public function logoutAll(Request $request): JsonResponse
	{
		$request->user()?->tokens()?->delete();
		return new JsonResponse(['success' => true, 'message' => 'Déconnecté de tous les appareils']);
	}

	/**
	 * POST /api/v1/auth/refresh (auth:sanctum)
	 * With Sanctum we mint a new token and revoke the current one.
	 */
	public function refresh(Request $request): JsonResponse
	{
		$user = $request->user();
		$request->user()?->currentAccessToken()?->delete();
		$newToken = $user->createToken('Refresh Token')->plainTextToken;
		return new JsonResponse([
			'success' => true,
			'message' => 'Token renouvelé',
			'data' => [
				'user' => [
					'id' => (string) $user->getKey(),
					'email' => $user->email,
					'phone' => $user->phone,
					'role' => optional($user->role)->name ?? 'user',
					'role_display_name' => optional($user->role)->display_name ?? 'Utilisateur',
					'permissions' => $user->role ? ($user->role->permissions()->pluck('name')->all() ?? []) : [],
					'organization_id' => $user->organization_id,
					'two_factor_enabled' => (bool) ($user->two_factor_enabled ?? false),
					'last_login_at' => optional($user->last_login_at)->toIso8601String(),
					'created_at' => optional($user->created_at)->toIso8601String(),
				],
				'token' => [
					'access_token' => $newToken,
					'token_type' => 'Bearer',
					'expires_at' => now()->addHours(8)->toIso8601String(),
				],
			],
		]);
	}

	/**
	 * GET /api/v1/auth/verify (auth:sanctum)
	 */
	public function verify(Request $request): JsonResponse
	{
		return new JsonResponse([
			'success' => true,
			'message' => 'Token valide',
			'data' => [
				'valid' => true,
				'expires_at' => now()->addHours(8)->toIso8601String(),
			],
		]);
	}

	/**
	 * POST /api/v1/auth/register
	 * Placeholder (not implemented in this phase)
	 */
	public function register(Request $request): JsonResponse
	{
		return new JsonResponse([
			'success' => false,
			'message' => 'Inscription non disponible',
		], 501);
	}
}

