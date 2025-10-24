<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Permission extends Model
{
    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'name',
        'description',
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Relation avec les rôles (many-to-many)
     */
    public function roles(): BelongsToMany
    {
        return $this->belongsToMany(Role::class, 'role_permissions');
    }

    /**
     * Scope pour les permissions système
     */
    public function scopeSystem($query)
    {
        return $query->whereIn('name', ['system_config', 'manage_users', 'view_audit_logs']);
    }

    /**
     * Scope pour les permissions de gestion des cas
     */
    public function scopeCaseManagement($query)
    {
        return $query->whereIn('name', ['view_reports', 'create_reports', 'edit_reports', 'assign_cases']);
    }

    /**
     * Scope pour les permissions sensibles
     */
    public function scopeSensitive($query)
    {
        return $query->whereIn('name', ['view_sensitive_data', 'export_data', 'manage_organizations']);
    }
}