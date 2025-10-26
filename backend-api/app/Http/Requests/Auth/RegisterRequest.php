<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;
use App\Models\Role;

/**
 * Form Request pour l'inscription
 * Validation stricte pour la sécurité VBG
 */
class RegisterRequest extends FormRequest
{
    /**
     * Détermine si l'utilisateur est autorisé à faire cette requête.
     */
    public function authorize(): bool
    {
        return true; // Inscription ouverte
    }

    /**
     * Règles de validation pour l'inscription.
     */
    public function rules(): array
    {
        return [
            'email' => [
                'nullable',
                'email:rfc,dns',
                'max:255',
                'unique:users,email',
                'required_without:phone'
            ],
            'phone' => [
                'nullable',
                'string',
                'regex:/^(\+[1-9]\d{1,14}|0[1-9]\d{8})$/', // Format international ou local
                'max:20',
                'unique:users,phone',
                'required_without:email'
            ],
            'password' => [
                'required',
                'confirmed',
                Password::min(8)
                    ->letters()
                    ->mixedCase()
                    ->numbers()
                    ->symbols()
                    ->uncompromised(), // Vérifier contre les fuites de données
            ],
            'role' => [
                'sometimes',
                'string',
                'in:' . implode(',', ['survivante', 'aps', 'operateur', 'organisation', 'superviseur']) // admin exclu
            ],
            'organization_id' => [
                'nullable',
                'uuid',
                'exists:organizations,id',
                'required_if:role,aps,operateur,organisation,superviseur'
            ],
            'terms_accepted' => [
                'required',
                'accepted'
            ],
            'privacy_policy_accepted' => [
                'required', 
                'accepted'
            ],
        ];
    }

    /**
     * Messages de validation personnalisés
     */
    public function messages(): array
    {
        return [
            'email.required_without' => 'L\'email est requis si le téléphone n\'est pas fourni.',
            'email.email' => 'Veuillez fournir une adresse email valide.',
            'email.unique' => 'Cette adresse email est déjà utilisée.',
            
            'phone.required_without' => 'Le téléphone est requis si l\'email n\'est pas fourni.',
            'phone.regex' => 'Le format du numéro de téléphone est invalide.',
            'phone.unique' => 'Ce numéro de téléphone est déjà utilisé.',
            
            'password.required' => 'Le mot de passe est requis.',
            'password.confirmed' => 'La confirmation du mot de passe ne correspond pas.',
            'password.min' => 'Le mot de passe doit contenir au moins 8 caractères.',
            
            'role.in' => 'Le rôle sélectionné est invalide.',
            
            'organization_id.required_if' => 'L\'organisation est requise pour ce type de rôle.',
            'organization_id.exists' => 'L\'organisation sélectionnée n\'existe pas.',
            
            'terms_accepted.accepted' => 'Vous devez accepter les conditions d\'utilisation.',
            'privacy_policy_accepted.accepted' => 'Vous devez accepter la politique de confidentialité.',
        ];
    }

    /**
     * Préparer les données pour la validation
     */
    protected function prepareForValidation(): void
    {
        // Nettoyer le numéro de téléphone
        if ($this->has('phone')) {
            $phone = preg_replace('/[^\d+]/', '', $this->phone);
            $this->merge(['phone' => $phone]);
        }

        // Normaliser l'email
        if ($this->has('email')) {
            $this->merge(['email' => strtolower(trim($this->email))]);
        }

        // Définir le rôle par défaut si non spécifié
        if (!$this->has('role')) {
            $this->merge(['role' => 'survivante']);
        }
    }

    /**
     * Obtenir les attributs validés avec processing supplémentaire
     */
    public function validatedWithProcessing(): array
    {
        $validated = $this->validated();
        
        // Hasher le mot de passe
        $validated['password'] = bcrypt($validated['password']);
        
        // Supprimer les champs de confirmation et d'acceptation
        unset($validated['password_confirmation']);
        unset($validated['terms_accepted']);
        unset($validated['privacy_policy_accepted']);
        
        return $validated;
    }

    /**
     * Validation après les règles de base
     */
    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            // Vérifier que le rôle existe et est actif
            if ($this->has('role')) {
                $role = Role::where('name', $this->role)->where('is_active', true)->first();
                if (!$role) {
                    $validator->errors()->add('role', 'Le rôle sélectionné n\'est pas disponible.');
                }
            }

            // Validation spécifique pour les rôles organisationnels
            if (in_array($this->role, ['aps', 'operateur', 'organisation', 'superviseur'])) {
                if (!$this->has('organization_id')) {
                    $validator->errors()->add('organization_id', 'Une organisation est requise pour ce rôle.');
                }
            }

            // Pour les survivantes, pas besoin d'organisation
            if ($this->role === 'survivante' && $this->has('organization_id')) {
                $validator->errors()->add('organization_id', 'Les survivantes ne peuvent pas être associées à une organisation.');
            }
        });
    }
}