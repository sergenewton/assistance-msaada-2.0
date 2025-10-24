<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Builder;

class Referral extends Model
{
    use HasUuids;

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'report_id',
        'organization_id',
        'referred_by',
        'service_type',
        'priority',
        'status',
        'response_deadline',
        'accepted_at',
        'accepted_by',
        'declined_at',
        'decline_reason',
        'completed_at',
        'notes',
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'response_deadline' => 'datetime',
        'accepted_at' => 'datetime',
        'declined_at' => 'datetime',
        'completed_at' => 'datetime',
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
     * Relation avec l'organisation destinataire
     */
    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    /**
     * Relation avec l'utilisateur qui a fait le référencement
     */
    public function referredBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'referred_by');
    }

    /**
     * Relation avec l'utilisateur qui a accepté le référencement
     */
    public function acceptedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'accepted_by');
    }

    /**
     * Mises à jour du référencement
     */
    public function updates(): HasMany
    {
        return $this->hasMany(ReferralUpdate::class)->orderBy('created_at', 'desc');
    }

    /**
     * Dernière mise à jour
     */
    public function latestUpdate()
    {
        return $this->hasOne(ReferralUpdate::class)->latestOfMany();
    }

    /**
     * Accepte le référencement
     */
    public function accept(User $user, ?string $comment = null): void
    {
        $this->update([
            'status' => 'accepted',
            'accepted_at' => now(),
            'accepted_by' => $user->id,
        ]);

        // Incrémenter la charge de l'organisation
        $this->organization->incrementLoad();

        // Créer une mise à jour
        $this->updates()->create([
            'updated_by' => $user->id,
            'status' => 'accepted',
            'comment' => $comment ?? 'Référencement accepté',
        ]);
    }

    /**
     * Refuse le référencement
     */
    public function decline(User $user, string $reason): void
    {
        $this->update([
            'status' => 'declined',
            'declined_at' => now(),
            'decline_reason' => $reason,
        ]);

        // Créer une mise à jour
        $this->updates()->create([
            'updated_by' => $user->id,
            'status' => 'declined',
            'comment' => $reason,
        ]);
    }

    /**
     * Marque le référencement comme complété
     */
    public function complete(User $user, ?string $comment = null, array $documents = []): void
    {
        $this->update([
            'status' => 'completed',
            'completed_at' => now(),
        ]);

        // Décrémenter la charge de l'organisation
        $this->organization->decrementLoad();

        // Créer une mise à jour
        $this->updates()->create([
            'updated_by' => $user->id,
            'status' => 'completed',
            'comment' => $comment ?? 'Service fourni avec succès',
            'documents' => $documents,
        ]);

        // Mettre à jour le score de performance de l'organisation
        $this->organization->updatePerformanceScore();
    }

    /**
     * Vérifie si le référencement est en retard
     */
    public function isOverdue(): bool
    {
        return $this->status === 'pending' && 
               $this->response_deadline < now();
    }

    /**
     * Vérifie si le référencement expire bientôt (dans les 24h)
     */
    public function isExpiringSoon(): bool
    {
        return $this->status === 'pending' && 
               $this->response_deadline <= now()->addDay();
    }

    /**
     * Calcule le temps de réponse en heures
     */
    public function getResponseTimeHours(): ?int
    {
        if (!$this->accepted_at) {
            return null;
        }

        return $this->created_at->diffInHours($this->accepted_at);
    }

    /**
     * Calcule le temps de traitement total en jours
     */
    public function getProcessingTimeDays(): ?int
    {
        if (!$this->completed_at) {
            return null;
        }

        return $this->created_at->diffInDays($this->completed_at);
    }

    /**
     * Scope pour les référencements en attente
     */
    public function scopePending(Builder $query): Builder
    {
        return $query->where('status', 'pending');
    }

    /**
     * Scope pour les référencements acceptés
     */
    public function scopeAccepted(Builder $query): Builder
    {
        return $query->where('status', 'accepted');
    }

    /**
     * Scope pour les référencements complétés
     */
    public function scopeCompleted(Builder $query): Builder
    {
        return $query->where('status', 'completed');
    }

    /**
     * Scope pour les référencements refusés
     */
    public function scopeDeclined(Builder $query): Builder
    {
        return $query->where('status', 'declined');
    }

    /**
     * Scope pour les référencements en retard
     */
    public function scopeOverdue(Builder $query): Builder
    {
        return $query->where('status', 'pending')
                    ->where('response_deadline', '<', now());
    }

    /**
     * Scope pour les référencements urgents
     */
    public function scopeUrgent(Builder $query): Builder
    {
        return $query->whereIn('priority', ['high', 'urgent']);
    }

    /**
     * Scope par type de service
     */
    public function scopeByServiceType(Builder $query, string $serviceType): Builder
    {
        return $query->where('service_type', $serviceType);
    }

    /**
     * Scope par organisation
     */
    public function scopeByOrganization(Builder $query, Organization $organization): Builder
    {
        return $query->where('organization_id', $organization->id);
    }

    /**
     * Scope par priorité
     */
    public function scopeByPriority(Builder $query, string $priority): Builder
    {
        return $query->where('priority', $priority);
    }

    /**
     * Scope pour les référencements récents
     */
    public function scopeRecent(Builder $query, int $days = 30): Builder
    {
        return $query->where('created_at', '>=', now()->subDays($days));
    }

    /**
     * Obtient la description du type de service
     */
    public function getServiceTypeDescriptionAttribute(): string
    {
        return match($this->service_type) {
            'psychological_support' => 'Support Psychologique',
            'medical_care' => 'Soins Médicaux',
            'legal_aid' => 'Aide Juridique',
            'shelter' => 'Hébergement',
            'economic_empowerment' => 'Autonomisation Économique',
            'police_protection' => 'Protection Policière',
            'child_protection' => 'Protection de l\'Enfant',
            'emergency_transport' => 'Transport d\'Urgence',
            default => $this->service_type
        };
    }

    /**
     * Obtient la description de la priorité
     */
    public function getPriorityDescriptionAttribute(): string
    {
        return match($this->priority) {
            'low' => 'Faible',
            'medium' => 'Moyenne',
            'high' => 'Élevée',
            'urgent' => 'Urgente',
            default => $this->priority
        };
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