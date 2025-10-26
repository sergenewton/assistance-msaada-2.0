<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\RateLimiter;

/**
 * Form Request pour la connexion
 * Validation avec sécurité renforcée et rate limiting
 */
class LoginRequest extends FormRequest
{
    /**
     * Détermine si l'utilisateur est autorisé à faire cette requête.
     */
    public function authorize(): bool
    {
        return true; // Connexion ouverte
    }

    /**
     * Règles de validation pour la connexion.
     */
    public function rules(): array
    {
        return [
            'identifier' => [
                'required',
                'string',
                'max:255'
            ],
            'password' => [
                'required',
                'string',
                'min:6', // Moins strict pour la connexion que pour l'inscription
                'max:255'
            ],
            'remember_me' => [
                'sometimes',
                'boolean'
            ],
            'device_name' => [
                'sometimes',
                'string',
                'max:100'
            ],
        ];
    }

    /**
     * Messages de validation personnalisés
     */
    public function messages(): array
    {
        return [
            'identifier.required' => 'L\'email ou le numéro de téléphone est requis.',
            'identifier.string' => 'L\'identifiant doit être une chaîne de caractères.',
            'identifier.max' => 'L\'identifiant ne peut pas dépasser 255 caractères.',
            
            'password.required' => 'Le mot de passe est requis.',
            'password.string' => 'Le mot de passe doit être une chaîne de caractères.',
            'password.min' => 'Le mot de passe doit contenir au moins 6 caractères.',
            'password.max' => 'Le mot de passe ne peut pas dépasser 255 caractères.',
            
            'remember_me.boolean' => 'La valeur "Se souvenir de moi" doit être vrai ou faux.',
            
            'device_name.string' => 'Le nom de l\'appareil doit être une chaîne de caractères.',
            'device_name.max' => 'Le nom de l\'appareil ne peut pas dépasser 100 caractères.',
        ];
    }

    /**
     * Préparer les données pour la validation
     */
    protected function prepareForValidation(): void
    {
        // Nettoyer l'identifiant (email ou téléphone)
        if ($this->has('identifier')) {
            $identifier = trim($this->identifier);
            
            // Si ça ressemble à un email, le normaliser
            if (filter_var($identifier, FILTER_VALIDATE_EMAIL)) {
                $identifier = strtolower($identifier);
            }
            // Si ça ressemble à un téléphone, le nettoyer
            elseif (preg_match('/^[\d+\-\s\(\)]+$/', $identifier)) {
                $identifier = preg_replace('/[^\d+]/', '', $identifier);
            }
            
            $this->merge(['identifier' => $identifier]);
        }

        // Définir le nom de l'appareil par défaut si non fourni
        if (!$this->has('device_name')) {
            $userAgent = $this->userAgent() ?? 'Unknown Device';
            $deviceName = $this->extractDeviceName($userAgent);
            $this->merge(['device_name' => $deviceName]);
        }
    }

    /**
     * Extraire un nom d'appareil lisible depuis le User-Agent
     */
    private function extractDeviceName(string $userAgent): string
    {
        // Mobile detection
        if (preg_match('/Mobile|Android|iPhone|iPad/', $userAgent)) {
            if (strpos($userAgent, 'iPhone') !== false) {
                return 'iPhone';
            } elseif (strpos($userAgent, 'iPad') !== false) {
                return 'iPad';
            } elseif (strpos($userAgent, 'Android') !== false) {
                return 'Android Device';
            } else {
                return 'Mobile Device';
            }
        }

        // Desktop browsers
        if (strpos($userAgent, 'Chrome') !== false) {
            return 'Chrome Browser';
        } elseif (strpos($userAgent, 'Firefox') !== false) {
            return 'Firefox Browser';
        } elseif (strpos($userAgent, 'Safari') !== false) {
            return 'Safari Browser';
        } elseif (strpos($userAgent, 'Edge') !== false) {
            return 'Edge Browser';
        }

        return 'Web Browser';
    }

    /**
     * Validation supplémentaire après les règles de base
     */
    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            // Vérifier le rate limiting AVANT la validation complète
            $key = 'login.' . $this->ip();
            if (RateLimiter::tooManyAttempts($key, 5)) {
                $seconds = RateLimiter::availableIn($key);
                $validator->errors()->add('identifier', 
                    'Trop de tentatives de connexion. Réessayez dans ' . $seconds . ' secondes.'
                );
                return;
            }

            // Valider le format de l'identifiant
            $identifier = $this->identifier;
            $isEmail = filter_var($identifier, FILTER_VALIDATE_EMAIL);
            $isPhone = preg_match('/^(\+[1-9]\d{1,14}|0[1-9]\d{8})$/', $identifier);

            if (!$isEmail && !$isPhone) {
                $validator->errors()->add('identifier', 
                    'L\'identifiant doit être un email valide ou un numéro de téléphone valide.'
                );
            }
        });
    }

    /**
     * Gérer un échec de validation
     */
    protected function failedValidation(\Illuminate\Contracts\Validation\Validator $validator): void
    {
        // Incrémenter le rate limiting même en cas d'échec de validation
        $key = 'login.' . $this->ip();
        RateLimiter::hit($key);

        parent::failedValidation($validator);
    }

    /**
     * Obtenir les données validées avec nettoyage
     */
    public function validatedWithSanitization(): array
    {
        $validated = $this->validated();
        
        // S'assurer que remember_me est un booléen
        $validated['remember_me'] = $this->boolean('remember_me', false);
        
        return $validated;
    }

    /**
     * Déterminer si la requête provient d'un appareil mobile
     */
    public function isMobileDevice(): bool
    {
        $userAgent = $this->userAgent() ?? '';
        return preg_match('/Mobile|Android|iPhone|iPad/', $userAgent) === 1;
    }

    /**
     * Obtenir une signature unique pour cet appareil/session
     */
    public function getDeviceSignature(): string
    {
        return hash('sha256', 
            $this->ip() . 
            $this->userAgent() . 
            ($this->device_name ?? 'unknown')
        );
    }
}