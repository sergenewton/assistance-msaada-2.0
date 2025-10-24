<?php

namespace App\Models;

use App\Traits\HasEncryptedAttributes;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, HasUuids, SoftDeletes, HasEncryptedAttributes;

    /**
     * Attributs chiffrés
     */
    protected $encrypted = [
        'email',
        'phone',
        'two_factor_secret',
    ];

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'email',
        'phone',
        'password',
        'role_id',
        'organization_id',
        'two_factor_enabled',
        'is_active',
    ];

    /**
     * The attributes that should be hidden for serialization.
     */
    protected $hidden = [
        'password',
        'two_factor_secret',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'two_factor_enabled' => 'boolean',
        'is_active' => 'boolean',
        'last_login_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
        'password' => 'hashed',
    ];

    /**
     * Relation avec le rôle
     */
    public function role(): BelongsTo
    {
        return $this->belongsTo(Role::class);
    }

    /**
     * Relation avec l'organisation
     */
    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    /**
     * Signalements créés par cet utilisateur
     */
    public function createdReports(): HasMany
    {
        return $this->hasMany(Report::class, 'reporter_id');
    }

    /**
     * Signalements assignés à cet utilisateur (APS)
     */
    public function assignedReports(): HasMany
    {
        return $this->hasMany(Report::class, 'assigned_aps_id');
    }

    /**
     * Référencements créés par cet utilisateur
     */
    public function referrals(): HasMany
    {
        return $this->hasMany(Referral::class, 'referred_by');
    }

    /**
     * Notifications de cet utilisateur
     */
    public function notifications(): HasMany
    {
        return $this->hasMany(Notification::class);
    }

    /**
     * Messages envoyés par cet utilisateur
     */
    public function messages(): HasMany
    {
        return $this->hasMany(Message::class, 'sender_id');
    }

    /**
     * Conversations en tant qu'APS
     */
    public function apsConversations(): HasMany
    {
        return $this->hasMany(Conversation::class, 'aps_id');
    }

    /**
     * Conversations en tant que survivante
     */
    public function survivorConversations(): HasMany
    {
        return $this->hasMany(Conversation::class, 'survivor_id');
    }

    /**
     * Articles créés par cet utilisateur
     */
    public function contentArticles(): HasMany
    {
        return $this->hasMany(ContentArticle::class, 'author_id');
    }

    /**
     * Vérifie si l'utilisateur a une permission
     */
    public function hasPermission(string $permission): bool
    {
        return $this->role && $this->role->hasPermission($permission);
    }

    /**
     * Vérifie si l'utilisateur a un rôle spécifique
     */
    public function hasRole(string $role): bool
    {
        return $this->role && $this->role->name === $role;
    }

    /**
     * Vérifie si l'utilisateur est un administrateur
     */
    public function isAdmin(): bool
    {
        return $this->hasRole('admin');
    }

    /**
     * Vérifie si l'utilisateur est un superviseur
     */
    public function isSupervisor(): bool
    {
        return $this->hasRole('superviseur');
    }

    /**
     * Vérifie si l'utilisateur est un APS
     */
    public function isAPS(): bool
    {
        return $this->hasRole('aps');
    }

    /**
     * Vérifie si l'utilisateur est une survivante
     */
    public function isSurvivor(): bool
    {
        return $this->hasRole('survivante');
    }

    /**
     * Scope pour les utilisateurs actifs
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope pour les APS disponibles
     */
    public function scopeAvailableAPS($query)
    {
        return $query->whereHas('role', function ($q) {
            $q->where('name', 'aps');
        })->where('is_active', true);
    }

    /**
     * Scope par rôle
     */
    public function scopeByRole($query, string $role)
    {
        return $query->whereHas('role', function ($q) use ($role) {
            $q->where('name', $role);
        });
    }

    /**
     * Mutator pour l'email chiffré
     */
    public function setEmailAttribute($value)
    {
        $this->setEncryptedAttribute('email', $value);
    }

    /**
     * Accessor pour l'email déchiffré
     */
    public function getEmailAttribute()
    {
        return $this->getEncryptedAttribute('email');
    }

    /**
     * Mutator pour le téléphone chiffré
     */
    public function setPhoneAttribute($value)
    {
        $this->setEncryptedAttribute('phone', $value);
    }

    /**
     * Accessor pour le téléphone déchiffré
     */
    public function getPhoneAttribute()
    {
        return $this->getEncryptedAttribute('phone');
    }

    /**
     * Mutator pour le secret 2FA chiffré
     */
    public function setTwoFactorSecretAttribute($value)
    {
        $this->setEncryptedAttribute('two_factor_secret', $value);
    }

    /**
     * Accessor pour le secret 2FA déchiffré
     */
    public function getTwoFactorSecretAttribute()
    {
        return $this->getEncryptedAttribute('two_factor_secret');
    }
}