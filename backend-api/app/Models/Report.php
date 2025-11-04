<?php

namespace App\Models;

use App\Traits\HasEncryptedAttributes;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\{BelongsTo, HasMany, HasOne};
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Builder;

class Report extends Model
{
    use HasUuids, SoftDeletes, HasEncryptedAttributes;

    /**
     * 🔒 Champs chiffrés
     */
    protected array $encrypted = [
        'narrative',
        'safety_code_word',
    ];

    /**
     * ✅ Attributs autorisés en écriture de masse
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
     * 🕶️ Champs à masquer dans les réponses JSON
     */
    protected $hidden = [
        'narrative',
        'safety_code_word',
    ];

    /**
     * 🎯 Casts automatiques
     */
    protected $casts = [
        'is_anonymous' => 'boolean',
        'is_safe_now' => 'boolean',
        'needs_urgent_medical' => 'boolean',
        'children_at_risk' => 'boolean',
        'death_threats' => 'boolean',
        'urgency_score' => 'integer',
        'incident_date' => 'datetime',
        'violence_types' => 'array',
        'incident_location_json' => 'array',
        'preferred_contact_methods' => 'array',
        'preferred_contact_hours' => 'array',
        'attachments' => 'array',
        'payload' => 'array',
        'assigned_at' => 'datetime',
        'closed_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    /* -------------------------------------------------------------------------
     | RELATIONS
     |--------------------------------------------------------------------------*/

    public function reporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reporter_id');
    }

    public function assignedAPS(): BelongsTo
    {
        return $this->belongsTo(User::class, 'assigned_aps_id');
    }

    public function needs(): HasMany
    {
        return $this->hasMany(ReportNeed::class);
    }

    public function files(): HasMany
    {
        return $this->hasMany(ReportFile::class);
    }

    public function referrals(): HasMany
    {
        return $this->hasMany(Referral::class);
    }

    public function conversations(): HasMany
    {
        return $this->hasMany(Conversation::class);
    }

    public function feedbacks(): HasMany
    {
        return $this->hasMany(Feedback::class);
    }

    public function activeConversation(): HasOne
    {
        return $this->hasOne(Conversation::class)->latestOfMany();
    }

    /* -------------------------------------------------------------------------
     | LOGIQUE MÉTIER
     |--------------------------------------------------------------------------*/

    /**
     * ⚙️ Calcul dynamique du score d'urgence
     */
    public function calculateUrgencyScore(): int
    {
        $score = match ($this->urgency_level) {
            'critical' => 40,
            'high'     => 30,
            'moderate' => 20,
            'low'      => 10,
            default    => 0,
        };

        if ($this->death_threats) $score += 25;
        if ($this->needs_urgent_medical) $score += 20;
        if ($this->children_at_risk) $score += 15;
        if (!$this->is_safe_now) $score += 15;
        if (in_array($this->violence_type, ['sexual', 'trafficking'])) $score += 10;
        if ($this->incident_frequency === 'chronic') $score += 10;

        return min(100, $score);
    }

    public function isCritical(): bool
    {
        return $this->urgency_level === 'critical'
            || $this->urgency_score >= 80
            || $this->death_threats
            || ($this->needs_urgent_medical && !$this->is_safe_now);
    }

    public function needsImmediateIntervention(): bool
    {
        return $this->death_threats
            || ($this->needs_urgent_medical && $this->urgency_level === 'critical');
    }

    public function assignToAPS(User $aps): void
    {
        $this->update([
            'assigned_aps_id' => $aps->id,
            'assigned_at' => now(),
            'status' => 'aps_assigned',
        ]);
    }

    public function close(string $reason): void
    {
        $this->update([
            'status' => 'closed',
            'closed_at' => now(),
            'closure_reason' => $reason,
        ]);
    }

    /* -------------------------------------------------------------------------
     | SCOPES (requêtes personnalisées)
     |--------------------------------------------------------------------------*/

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('status', '!=', 'closed');
    }

    public function scopeByStatus(Builder $query, string $status): Builder
    {
        return $query->where('status', $status);
    }

    public function scopeUrgent(Builder $query): Builder
    {
        return $query->whereIn('urgency_level', ['high', 'critical']);
    }

    public function scopeCritical(Builder $query): Builder
    {
        return $query->where(function ($q) {
            $q->where('urgency_level', 'critical')
              ->orWhere('urgency_score', '>=', 80)
              ->orWhere('death_threats', true);
        });
    }

    public function scopeUnassigned(Builder $query): Builder
    {
        return $query->whereNull('assigned_aps_id')
                     ->where('status', 'new');
    }

    public function scopeByViolenceType(Builder $query, string $type): Builder
    {
        return $query->where('violence_type', $type)
                     ->orWhereJsonContains('violence_types', $type);
    }

    public function scopeByProvince(Builder $query, string $province): Builder
    {
        return $query->where('location_province', $province);
    }

    public function scopeAssignedTo(Builder $query, User $aps): Builder
    {
        return $query->where('assigned_aps_id', $aps->id);
    }

    public function scopeRecent(Builder $query, int $days = 30): Builder
    {
        return $query->where('created_at', '>=', now()->subDays($days));
    }

    /* -------------------------------------------------------------------------
     | ENCRYPTION ACCESSORS / MUTATORS
     |--------------------------------------------------------------------------*/

    public function setNarrativeAttribute($value): void
    {
        $this->setEncryptedAttribute('narrative', $value);
    }

    public function getNarrativeAttribute(): ?string
    {
        return $this->getEncryptedAttribute('narrative');
    }

    public function setSafetyCodeWordAttribute($value): void
    {
        $this->setEncryptedAttribute('safety_code_word', $value);
    }

    public function getSafetyCodeWordAttribute(): ?string
    {
        return $this->getEncryptedAttribute('safety_code_word');
    }

    /* -------------------------------------------------------------------------
     | BOOT (logique automatique)
     |--------------------------------------------------------------------------*/

    protected static function boot()
    {
        parent::boot();

        static::saving(function (Report $report) {
            if ($report->isDirty([
                'urgency_level',
                'death_threats',
                'needs_urgent_medical',
                'children_at_risk',
                'is_safe_now',
                'violence_type',
                'incident_frequency',
            ])) {
                $report->urgency_score = $report->calculateUrgencyScore();
            }
        });
    }
}
