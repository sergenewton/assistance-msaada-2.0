<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ReportNeed extends Model
{
    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'report_id',
        'need_type',
        'priority',
        'is_fulfilled',
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'priority' => 'integer',
        'is_fulfilled' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Relation avec le signalement
     */
    public function report(): BelongsTo
    {
        return $this->belongsTo(Report::class);
    }

    /**
     * Marque le besoin comme satisfait
     */
    public function markAsFulfilled(): void
    {
        $this->update(['is_fulfilled' => true]);
    }

    /**
     * Marque le besoin comme non satisfait
     */
    public function markAsUnfulfilled(): void
    {
        $this->update(['is_fulfilled' => false]);
    }

    /**
     * Scope pour les besoins non satisfaits
     */
    public function scopeUnfulfilled($query)
    {
        return $query->where('is_fulfilled', false);
    }

    /**
     * Scope pour les besoins satisfaits
     */
    public function scopeFulfilled($query)
    {
        return $query->where('is_fulfilled', true);
    }

    /**
     * Scope par type de besoin
     */
    public function scopeByType($query, string $type)
    {
        return $query->where('need_type', $type);
    }

    /**
     * Scope par priorité
     */
    public function scopeByPriority($query, int $priority)
    {
        return $query->where('priority', $priority);
    }

    /**
     * Scope pour les besoins urgents (priorité 4-5)
     */
    public function scopeUrgent($query)
    {
        return $query->whereIn('priority', [4, 5]);
    }

    /**
     * Vérifie si le besoin est urgent
     */
    public function isUrgent(): bool
    {
        return $this->priority >= 4;
    }

    /**
     * Obtient la description du type de besoin
     */
    public function getTypeDescriptionAttribute(): string
    {
        return match($this->need_type) {
            'psychological' => 'Support Psychologique',
            'medical' => 'Soins Médicaux',
            'legal' => 'Aide Juridique',
            'shelter' => 'Hébergement',
            'economic' => 'Assistance Économique',
            'police' => 'Protection Policière',
            default => $this->need_type
        };
    }

    /**
     * Obtient la description de la priorité
     */
    public function getPriorityDescriptionAttribute(): string
    {
        return match($this->priority) {
            1 => 'Très faible',
            2 => 'Faible',
            3 => 'Moyenne',
            4 => 'Élevée',
            5 => 'Critique',
            default => 'Non définie'
        };
    }
}