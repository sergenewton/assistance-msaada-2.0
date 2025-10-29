<?php

namespace App\Models;

use App\Traits\HasEncryptedAttributes;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Builder;

class Report extends Model
{
    use HasUuids, SoftDeletes, HasEncryptedAttributes;

    /**
     * Attributs chiffrés
     */
    protected $encrypted = [
        'narrative',
        'safety_code_word',
    ];

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'report_number',
        'reporter_id',
        'reporter_name',
        'victim_name',
        'contact_number',
        'is_anonymous',
        'violence_type',
        'violence_types',
        'urgency_level',
        'urgency_score',
        'victim_age_range',
        'victim_gender',
        'victim_status',
        'incident_date',
        'incident_location',
        'incident_location_json',
        'address_line',
        'latitude',
        'longitude',
        'incident_frequency',
        'narrative',
        'perpetrator_relationship',
        'is_safe_now',
        'needs_urgent_medical',
        'children_at_risk',
        'death_threats',
        'location_province',
        'location_commune',
        'location_quartier',
        'preferred_contact_method',
        'preferred_contact_methods',
        'preferred_contact_hours',
        'safety_code_word',
        'status',
        'assigned_aps_id',
        'assigned_at',
        'closed_at',
        'closure_reason',
        'payload',
        'attachments',
    ];

    /**
     * The attributes that should be hidden for serialization.
     */
    protected $hidden = [
        'narrative',
        'safety_code_word',
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'is_anonymous' => 'boolean',
        'urgency_score' => 'integer',
        'incident_date' => 'date',
        'is_safe_now' => 'boolean',
        'needs_urgent_medical' => 'boolean',
        'children_at_risk' => 'boolean',
        'death_threats' => 'boolean',
        'violence_types' => 'array',
        'incident_location_json' => 'array',
        'preferred_contact_methods' => 'array',
        'attachments' => 'array',
        'payload' => 'array',
        'preferred_contact_hours' => 'array',
        'assigned_at' => 'datetime',
        'closed_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    /**
     * Relation avec l'utilisateur rapporteur
     */
    public function reporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reporter_id');
    }

    /**
     * Relation avec l'APS assigné
     */
    public function assignedAPS(): BelongsTo
    {
        return $this->belongsTo(User::class, 'assigned_aps_id');
    }

    /**
     * Besoins associés au signalement
     */
    public function needs(): HasMany
    {
        return $this->hasMany(ReportNeed::class);
    }

    /**
     * Fichiers joints au signalement
     */
    public function files(): HasMany
    {
        return $this->hasMany(ReportFile::class);
    }

    /**
     * Référencements créés pour ce signalement
     */
    public function referrals(): HasMany
    {
        return $this->hasMany(Referral::class);
    }

    /**
     * Conversations liées à ce signalement
     */
    public function conversations(): HasMany
    {
        return $this->hasMany(Conversation::class);
    }

    /**
     * Feedbacks pour ce signalement
     */
    public function feedbacks(): HasMany
    {
        return $this->hasMany(Feedback::class);
    }

    /**
     * Conversation active (la plus récente)
     */
    public function activeConversation(): HasOne
    {
        return $this->hasOne(Conversation::class)->latest();
    }

    /**
     * Calcule le score d'urgence basé sur les facteurs de risque
     */
    public function calculateUrgencyScore(): int
    {
        $score = 0;

        // Facteurs de base
        switch ($this->urgency_level) {
            case 'critical':
                $score += 40;
                break;
            case 'high':
                $score += 30;
                break;
            case 'moderate':
                $score += 20;
                break;
            case 'low':
                $score += 10;
                break;
        }

        // Facteurs de risque additionnels
        if ($this->death_threats) $score += 25;
        if ($this->needs_urgent_medical) $score += 20;
        if ($this->children_at_risk) $score += 15;
        if (!$this->is_safe_now) $score += 15;

        // Type de violence
        if (in_array($this->violence_type, ['sexual', 'trafficking'])) {
            $score += 10;
        }

        // Fréquence
        if ($this->incident_frequency === 'chronic') {
            $score += 10;
        }

        return min(100, $score);
    }

    /**
     * Vérifie si le signalement est critique
     */
    public function isCritical(): bool
    {
        return $this->urgency_level === 'critical' || 
               $this->urgency_score >= 80 ||
               $this->death_threats ||
               ($this->needs_urgent_medical && !$this->is_safe_now);
    }

    /**
     * Vérifie si le signalement nécessite une intervention immédiate
     */
    public function needsImmediateIntervention(): bool
    {
        return $this->death_threats || 
               ($this->needs_urgent_medical && $this->urgency_level === 'critical');
    }

    /**
     * Assigne un APS au signalement
     */
    public function assignToAPS(User $aps): void
    {
        $this->update([
            'assigned_aps_id' => $aps->id,
            'assigned_at' => now(),
            'status' => 'aps_assigned',
        ]);
    }

    /**
     * Ferme le signalement
     */
    public function close(string $reason): void
    {
        $this->update([
            'status' => 'closed',
            'closed_at' => now(),
            'closure_reason' => $reason,
        ]);
    }

    /**
     * Scope pour les signalements actifs (non fermés)
     */
    public function scopeActive(Builder $query): Builder
    {
        return $query->where('status', '!=', 'closed');
    }

    /**
     * Scope pour les signalements par statut
     */
    public function scopeByStatus(Builder $query, string $status): Builder
    {
        return $query->where('status', $status);
    }

    /**
     * Scope pour les signalements urgents
     */
    public function scopeUrgent(Builder $query): Builder
    {
        return $query->whereIn('urgency_level', ['high', 'critical']);
    }

    /**
     * Scope pour les signalements critiques
     */
    public function scopeCritical(Builder $query): Builder
    {
        return $query->where('urgency_level', 'critical')
                    ->orWhere('urgency_score', '>=', 80)
                    ->orWhere('death_threats', true);
    }

    /**
     * Scope pour les signalements non assignés
     */
    public function scopeUnassigned(Builder $query): Builder
    {
        return $query->whereNull('assigned_aps_id')
                    ->where('status', 'new');
    }

    /**
     * Scope par type de violence
     */
    public function scopeByViolenceType(Builder $query, string $type): Builder
    {
        return $query->where('violence_type', $type);
    }

    /**
     * Scope par province
     */
    public function scopeByProvince(Builder $query, string $province): Builder
    {
        return $query->where('location_province', $province);
    }

    /**
     * Scope pour les signalements assignés à un APS
     */
    public function scopeAssignedTo(Builder $query, User $aps): Builder
    {
        return $query->where('assigned_aps_id', $aps->id);
    }

    /**
     * Scope pour les signalements récents
     */
    public function scopeRecent(Builder $query, int $days = 30): Builder
    {
        return $query->where('created_at', '>=', now()->subDays($days));
    }

    /**
     * Mutator pour le narratif chiffré
     */
    public function setNarrativeAttribute($value)
    {
        $this->setEncryptedAttribute('narrative', $value);
    }

    /**
     * Accessor pour le narratif déchiffré
     */
    public function getNarrativeAttribute()
    {
        return $this->getEncryptedAttribute('narrative');
    }

    /**
     * Mutator pour le mot de code de sécurité chiffré
     */
    public function setSafetyCodeWordAttribute($value)
    {
        $this->setEncryptedAttribute('safety_code_word', $value);
    }

    /**
     * Accessor pour le mot de code de sécurité déchiffré
     */
    public function getSafetyCodeWordAttribute()
    {
        return $this->getEncryptedAttribute('safety_code_word');
    }

    /**
     * Boot du modèle pour auto-calculer le score d'urgence
     */
    protected static function boot()
    {
        parent::boot();

        static::saving(function ($report) {
            if ($report->isDirty(['urgency_level', 'death_threats', 'needs_urgent_medical', 'children_at_risk', 'is_safe_now', 'violence_type', 'incident_frequency'])) {
                $report->urgency_score = $report->calculateUrgencyScore();
            }
        });
    }
}