<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ReferralUpdate extends Model
{
    /**
     * Disable updated_at timestamp as we only track creation
     */
    const UPDATED_AT = null;

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'referral_id',
        'updated_by',
        'status',
        'comment',
        'documents',
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'documents' => 'array',
        'created_at' => 'datetime',
    ];

    /**
     * Relation avec le référencement
     */
    public function referral(): BelongsTo
    {
        return $this->belongsTo(Referral::class);
    }

    /**
     * Relation avec l'utilisateur qui a fait la mise à jour
     */
    public function updatedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'updated_by');
    }

    /**
     * Scope par statut
     */
    public function scopeByStatus($query, string $status)
    {
        return $query->where('status', $status);
    }

    /**
     * Scope pour les mises à jour récentes
     */
    public function scopeRecent($query, int $days = 7)
    {
        return $query->where('created_at', '>=', now()->subDays($days));
    }

    /**
     * Vérifie si la mise à jour contient des documents
     */
    public function hasDocuments(): bool
    {
        return !empty($this->documents);
    }

    /**
     * Obtient le nombre de documents
     */
    public function getDocumentsCountAttribute(): int
    {
        return count($this->documents ?? []);
    }

    /**
     * Obtient la description du statut
     */
    public function getStatusDescriptionAttribute(): string
    {
        return match($this->status) {
            'pending' => 'En attente',
            'accepted' => 'Accepté',
            'declined' => 'Refusé',
            'completed' => 'Complété',
            default => $this->status
        };
    }
}