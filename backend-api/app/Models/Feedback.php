<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Builder;

class Feedback extends Model
{
    use HasUuids;

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'report_id',
        'feedback_type',
        'rating',
        'questions_answers',
        'comment',
        'submitted_at',
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'rating' => 'integer',
        'questions_answers' => 'array',
        'submitted_at' => 'datetime',
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
     * Obtient une réponse à une question spécifique
     */
    public function getAnswer(string $question, $default = null)
    {
        return data_get($this->questions_answers, $question, $default);
    }

    /**
     * Définit une réponse à une question
     */
    public function setAnswer(string $question, $answer): void
    {
        $qa = $this->questions_answers ?? [];
        $qa[$question] = $answer;
        $this->update(['questions_answers' => $qa]);
    }

    /**
     * Vérifie si le feedback a un rating
     */
    public function hasRating(): bool
    {
        return !is_null($this->rating);
    }

    /**
     * Vérifie si le feedback est positif (rating >= 4)
     */
    public function isPositive(): bool
    {
        return $this->rating && $this->rating >= 4;
    }

    /**
     * Vérifie si le feedback est négatif (rating <= 2)
     */
    public function isNegative(): bool
    {
        return $this->rating && $this->rating <= 2;
    }

    /**
     * Vérifie si le feedback est neutre (rating = 3)
     */
    public function isNeutral(): bool
    {
        return $this->rating === 3;
    }

    /**
     * Obtient la description du rating
     */
    public function getRatingDescriptionAttribute(): ?string
    {
        return match($this->rating) {
            1 => 'Très insatisfait',
            2 => 'Insatisfait',
            3 => 'Neutre',
            4 => 'Satisfait',
            5 => 'Très satisfait',
            default => null
        };
    }

    /**
     * Obtient la description du type de feedback
     */
    public function getTypeDescriptionAttribute(): string
    {
        return match($this->feedback_type) {
            'first_contact' => 'Premier contact',
            'referral' => 'Référencement',
            'closure' => 'Clôture du cas',
            'follow_up' => 'Suivi',
            default => $this->feedback_type
        };
    }

    /**
     * Scope par type de feedback
     */
    public function scopeByType(Builder $query, string $type): Builder
    {
        return $query->where('feedback_type', $type);
    }

    /**
     * Scope pour les feedbacks avec rating
     */
    public function scopeWithRating(Builder $query): Builder
    {
        return $query->whereNotNull('rating');
    }

    /**
     * Scope pour les feedbacks positifs
     */
    public function scopePositive(Builder $query): Builder
    {
        return $query->where('rating', '>=', 4);
    }

    /**
     * Scope pour les feedbacks négatifs
     */
    public function scopeNegative(Builder $query): Builder
    {
        return $query->where('rating', '<=', 2);
    }

    /**
     * Scope pour les feedbacks neutres
     */
    public function scopeNeutral(Builder $query): Builder
    {
        return $query->where('rating', 3);
    }

    /**
     * Scope pour les feedbacks avec commentaires
     */
    public function scopeWithComments(Builder $query): Builder
    {
        return $query->whereNotNull('comment')
                    ->where('comment', '!=', '');
    }

    /**
     * Scope pour les feedbacks récents
     */
    public function scopeRecent(Builder $query, int $days = 30): Builder
    {
        return $query->where('submitted_at', '>=', now()->subDays($days));
    }

    /**
     * Scope par période
     */
    public function scopeBetweenDates(Builder $query, $startDate, $endDate): Builder
    {
        return $query->whereBetween('submitted_at', [$startDate, $endDate]);
    }

    /**
     * Scope ordonné par date de soumission (plus récent en premier)
     */
    public function scopeLatest(Builder $query): Builder
    {
        return $query->orderBy('submitted_at', 'desc');
    }

    /**
     * Méthodes statiques pour calculer les statistiques
     */
    public static function getAverageRating(?string $feedbackType = null): float
    {
        $query = static::whereNotNull('rating');
        
        if ($feedbackType) {
            $query->where('feedback_type', $feedbackType);
        }

        return round($query->avg('rating') ?? 0, 2);
    }

    /**
     * Obtient la distribution des ratings
     */
    public static function getRatingDistribution(?string $feedbackType = null): array
    {
        $query = static::whereNotNull('rating');
        
        if ($feedbackType) {
            $query->where('feedback_type', $feedbackType);
        }

        $distribution = $query->selectRaw('rating, COUNT(*) as count')
                             ->groupBy('rating')
                             ->orderBy('rating')
                             ->pluck('count', 'rating')
                             ->toArray();

        // Assurer que tous les ratings (1-5) sont présents
        $result = [];
        for ($i = 1; $i <= 5; $i++) {
            $result[$i] = $distribution[$i] ?? 0;
        }

        return $result;
    }

    /**
     * Obtient le pourcentage de satisfaction
     */
    public static function getSatisfactionRate(?string $feedbackType = null): float
    {
        $query = static::whereNotNull('rating');
        
        if ($feedbackType) {
            $query->where('feedback_type', $feedbackType);
        }

        $total = $query->count();
        
        if ($total === 0) {
            return 0;
        }

        $positive = $query->where('rating', '>=', 4)->count();
        
        return round(($positive / $total) * 100, 2);
    }

    /**
     * Boot du modèle pour définir submitted_at automatiquement
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($feedback) {
            if (!$feedback->submitted_at) {
                $feedback->submitted_at = now();
            }
        });
    }
}