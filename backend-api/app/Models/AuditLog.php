<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Builder;

class AuditLog extends Model
{
    /**
     * Disable updated_at timestamp as audit logs are immutable
     */
    const UPDATED_AT = null;

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'user_id',
        'action',
        'resource_type',
        'resource_id',
        'ip_address',
        'user_agent',
        'changes',
        'severity',
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'changes' => 'array',
        'created_at' => 'datetime',
    ];

    /**
     * Relation avec l'utilisateur qui a effectué l'action
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Obtient les anciennes valeurs des changements
     */
    public function getOldValuesAttribute(): ?array
    {
        return data_get($this->changes, 'old_values');
    }

    /**
     * Obtient les nouvelles valeurs des changements
     */
    public function getNewValuesAttribute(): ?array
    {
        return data_get($this->changes, 'new_values');
    }

    /**
     * Vérifie si l'audit log contient des changements
     */
    public function hasAuditChanges(): bool
    {
        return !empty($this->changes);
    }

    /**
     * Obtient une valeur spécifique des anciennes données
     */
    public function getOldValue(string $key, $default = null)
    {
        return data_get($this->old_values, $key, $default);
    }

    /**
     * Obtient une valeur spécifique des nouvelles données
     */
    public function getNewValue(string $key, $default = null)
    {
        return data_get($this->new_values, $key, $default);
    }

    /**
     * Vérifie si un champ spécifique a changé
     */
    public function hasFieldChanged(string $field): bool
    {
        if (!$this->hasAuditChanges()) {
            return false;
        }

        $oldValues = $this->old_values ?? [];
        $newValues = $this->new_values ?? [];

        return isset($oldValues[$field]) || isset($newValues[$field]);
    }

    /**
     * Obtient la description de l'action
     */
    public function getActionDescriptionAttribute(): string
    {
        return match($this->action) {
            'created' => 'Créé',
            'updated' => 'Mis à jour',
            'deleted' => 'Supprimé',
            'viewed' => 'Consulté',
            'exported' => 'Exporté',
            'assigned' => 'Assigné',
            'closed' => 'Fermé',
            'referred' => 'Référé',
            'accepted' => 'Accepté',
            'declined' => 'Refusé',
            'completed' => 'Complété',
            'login' => 'Connexion',
            'logout' => 'Déconnexion',
            default => $this->action
        };
    }

    /**
     * Obtient la description de la sévérité
     */
    public function getSeverityDescriptionAttribute(): string
    {
        return match($this->severity) {
            'info' => 'Information',
            'warning' => 'Avertissement',
            'critical' => 'Critique',
            default => $this->severity
        };
    }

    /**
     * Obtient la couleur associée à la sévérité (pour l'UI)
     */
    public function getSeverityColorAttribute(): string
    {
        return match($this->severity) {
            'info' => 'blue',
            'warning' => 'yellow',
            'critical' => 'red',
            default => 'gray'
        };
    }

    /**
     * Scope par utilisateur
     */
    public function scopeByUser(Builder $query, User $user): Builder
    {
        return $query->where('user_id', $user->id);
    }

    /**
     * Scope par action
     */
    public function scopeByAction(Builder $query, string $action): Builder
    {
        return $query->where('action', $action);
    }

    /**
     * Scope par type de ressource
     */
    public function scopeByResourceType(Builder $query, string $resourceType): Builder
    {
        return $query->where('resource_type', $resourceType);
    }

    /**
     * Scope par ressource spécifique
     */
    public function scopeByResource(Builder $query, string $resourceType, string $resourceId): Builder
    {
        return $query->where('resource_type', $resourceType)
                    ->where('resource_id', $resourceId);
    }

    /**
     * Scope par sévérité
     */
    public function scopeBySeverity(Builder $query, string $severity): Builder
    {
        return $query->where('severity', $severity);
    }

    /**
     * Scope pour les actions critiques
     */
    public function scopeCritical(Builder $query): Builder
    {
        return $query->where('severity', 'critical');
    }

    /**
     * Scope pour les actions sensibles
     */
    public function scopeSensitiveActions(Builder $query): Builder
    {
        return $query->whereIn('action', [
            'viewed_sensitive_data',
            'exported_data',
            'deleted',
            'accessed_admin_panel'
        ]);
    }

    /**
     * Scope pour une période spécifique
     */
    public function scopeBetweenDates(Builder $query, $startDate, $endDate): Builder
    {
        return $query->whereBetween('created_at', [$startDate, $endDate]);
    }

    /**
     * Scope pour aujourd'hui
     */
    public function scopeToday(Builder $query): Builder
    {
        return $query->whereDate('created_at', now()->toDateString());
    }

    /**
     * Scope pour cette semaine
     */
    public function scopeThisWeek(Builder $query): Builder
    {
        return $query->whereBetween('created_at', [
            now()->startOfWeek(),
            now()->endOfWeek()
        ]);
    }

    /**
     * Scope pour ce mois
     */
    public function scopeThisMonth(Builder $query): Builder
    {
        return $query->whereMonth('created_at', now()->month)
                    ->whereYear('created_at', now()->year);
    }

    /**
     * Scope ordonné par date (plus récent en premier)
     */
    public function scopeLatest(Builder $query): Builder
    {
        return $query->orderBy('created_at', 'desc');
    }

    /**
     * Méthode statique pour créer un log d'audit
     */
    public static function log(
        string $action,
        string $resourceType,
        string $resourceId,
        ?User $user = null,
        ?array $changes = null,
        string $severity = 'info',
        ?string $ipAddress = null,
        ?string $userAgent = null
    ): self {
        return static::create([
            'user_id' => $user?->id,
            'action' => $action,
            'resource_type' => $resourceType,
            'resource_id' => $resourceId,
            'ip_address' => $ipAddress ?? request()->ip(),
            'user_agent' => $userAgent ?? request()->userAgent(),
            'changes' => $changes,
            'severity' => $severity,
        ]);
    }

    /**
     * Méthode statique pour logger une visualisation de données sensibles
     */
    public static function logSensitiveDataAccess(
        string $resourceType,
        string $resourceId,
        User $user,
        ?string $details = null
    ): self {
        return static::log(
            'viewed_sensitive_data',
            $resourceType,
            $resourceId,
            $user,
            ['details' => $details],
            'warning'
        );
    }

    /**
     * Méthode statique pour logger une exportation de données
     */
    public static function logDataExport(
        string $exportType,
        User $user,
        array $filters = [],
        int $recordCount = 0
    ): self {
        return static::log(
            'exported_data',
            'Export',
            uniqid(),
            $user,
            [
                'export_type' => $exportType,
                'filters' => $filters,
                'record_count' => $recordCount
            ],
            'warning'
        );
    }

    /**
     * Méthode statique pour logger une connexion
     */
    public static function logLogin(User $user, bool $successful = true): self
    {
        return static::log(
            $successful ? 'login' : 'login_failed',
            'User',
            $user->id,
            $user,
            ['successful' => $successful],
            $successful ? 'info' : 'warning'
        );
    }

    /**
     * Méthode statique pour logger une déconnexion
     */
    public static function logLogout(User $user): self
    {
        return static::log(
            'logout',
            'User',
            $user->id,
            $user,
            null,
            'info'
        );
    }
}