<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Organization extends Model
{
    use HasUuids, SoftDeletes;

    /**
     * ✅ Attributs assignables en masse
     */
    protected $fillable = [
        'name',
        'type',
        'sector',
        'address',
        'contact_phone',
        'contact_email',
        'contact_person',
        'services_offered',
        'specialties',
        'availability',
        'province',
        'commune',
        'is_active',
        'max_capacity',
        'current_load',
        'languages_spoken',
        'performance_score',
    ];

    /**
     * 🎯 Casts automatiques
     */
    protected $casts = [
        'services_offered' => 'array',
        'specialties' => 'array',
        'languages_spoken' => 'array',
        'is_active' => 'boolean',
        'max_capacity' => 'integer',
        'current_load' => 'integer',
        'performance_score' => 'decimal:2',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    /**
     * 👥 Relations
     */
    public function users(): HasMany
    {
        return $this->hasMany(User::class);
    }

    public function referrals(): HasMany
    {
        return $this->hasMany(Referral::class);
    }

    public function pendingReferrals(): HasMany
    {
        return $this->referrals()->where('status', 'pending');
    }

    public function acceptedReferrals(): HasMany
    {
        return $this->referrals()->where('status', 'accepted');
    }

    /**
     * 📊 Calcul du pourcentage de capacité utilisée
     */
    public function getCapacityPercentageAttribute(): float
    {
        if (!$this->max_capacity || $this->max_capacity == 0) {
            return 0;
        }
        return round(($this->current_load / $this->max_capacity) * 100, 2);
    }

    /**
     * 🟢 Vérifie si l’organisation peut accepter de nouveaux cas
     */
    public function canAcceptNewCases(): bool
    {
        if (!$this->is_active) {
            return false;
        }

        if (!$this->max_capacity) {
            return true; // pas de limite
        }

        return $this->current_load < $this->max_capacity;
    }

    /**
     * 🎯 Vérifie si l'organisation a une spécialité donnée
     */
    public function hasSpecialty(string $specialty): bool
    {
        return in_array($specialty, $this->specialties ?? []);
    }

    /**
     * 🗣️ Vérifie si l'organisation parle une langue donnée
     */
    public function speaksLanguage(string $language): bool
    {
        return in_array($language, $this->languages_spoken ?? []);
    }

    /**
     * 🔍 Scopes dynamiques
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeByType($query, string $type)
    {
        return $query->where('type', $type);
    }

    public function scopeByProvince($query, string $province)
    {
        return $query->where('province', $province);
    }

    public function scopeAvailable($query)
    {
        return $query->where('is_active', true)
            ->where(function ($q) {
                $q->whereNull('max_capacity')
                  ->orWhereColumn('current_load', '<', 'max_capacity');
            });
    }

    public function scopeWithSpecialty($query, string $specialty)
    {
        return $query->whereJsonContains('specialties', $specialty);
    }

    public function scopeWithLanguage($query, string $language)
    {
        return $query->whereJsonContains('languages_spoken', $language);
    }

    public function scopeWithMinPerformance($query, float $minScore)
    {
        return $query->where('performance_score', '>=', $minScore);
    }

    /**
     * ⚙️ Gestion de la charge
     */
    public function incrementLoad(): void
    {
        $this->increment('current_load');
    }

    public function decrementLoad(): void
    {
        $this->decrement('current_load');
    }

    /**
     * 🧮 Met à jour le score de performance basé sur les référencements
     */
    public function updatePerformanceScore(): void
    {
        $completedReferrals = $this->referrals()
            ->where('status', 'completed')
            ->where('created_at', '>=', now()->subMonths(6))
            ->get();

        if ($completedReferrals->count() === 0) {
            return;
        }

        $avgResponseTime = $completedReferrals->avg(function ($referral) {
            return $referral->accepted_at
                ? $referral->created_at->diffInHours($referral->accepted_at)
                : 0;
        });

        $responseScore = max(0, min(5, 5 - ($avgResponseTime / 24)));

        $this->update(['performance_score' => round($responseScore, 2)]);
    }
}
