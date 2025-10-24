<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;

class FAQ extends Model
{
    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'question',
        'answer',
        'category',
        'order_index',
        'is_published',
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'question' => 'array',
        'answer' => 'array',
        'order_index' => 'integer',
        'is_published' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Obtient la question dans une langue spécifique
     */
    public function getQuestionInLanguage(string $language = 'fr'): string
    {
        return $this->question[$language] ?? $this->question['fr'] ?? '';
    }

    /**
     * Obtient la réponse dans une langue spécifique
     */
    public function getAnswerInLanguage(string $language = 'fr'): string
    {
        return $this->answer[$language] ?? $this->answer['fr'] ?? '';
    }

    /**
     * Définit la question dans une langue spécifique
     */
    public function setQuestionInLanguage(string $language, string $question): void
    {
        $questions = $this->question ?? [];
        $questions[$language] = $question;
        $this->update(['question' => $questions]);
    }

    /**
     * Définit la réponse dans une langue spécifique
     */
    public function setAnswerInLanguage(string $language, string $answer): void
    {
        $answers = $this->answer ?? [];
        $answers[$language] = $answer;
        $this->update(['answer' => $answers]);
    }

    /**
     * Obtient les langues disponibles pour cette FAQ
     */
    public function getAvailableLanguagesAttribute(): array
    {
        $questionLanguages = array_keys($this->question ?? []);
        $answerLanguages = array_keys($this->answer ?? []);
        
        return array_unique(array_merge($questionLanguages, $answerLanguages));
    }

    /**
     * Vérifie si la FAQ est disponible dans une langue
     */
    public function isAvailableInLanguage(string $language): bool
    {
        return in_array($language, $this->available_languages);
    }

    /**
     * Publie la FAQ
     */
    public function publish(): void
    {
        $this->update(['is_published' => true]);
    }

    /**
     * Dépublie la FAQ
     */
    public function unpublish(): void
    {
        $this->update(['is_published' => false]);
    }

    /**
     * Déplace la FAQ vers le haut dans l'ordre
     */
    public function moveUp(): void
    {
        $previousFaq = static::where('category', $this->category)
            ->where('order_index', '<', $this->order_index)
            ->orderBy('order_index', 'desc')
            ->first();

        if ($previousFaq) {
            $tempOrder = $this->order_index;
            $this->update(['order_index' => $previousFaq->order_index]);
            $previousFaq->update(['order_index' => $tempOrder]);
        }
    }

    /**
     * Déplace la FAQ vers le bas dans l'ordre
     */
    public function moveDown(): void
    {
        $nextFaq = static::where('category', $this->category)
            ->where('order_index', '>', $this->order_index)
            ->orderBy('order_index', 'asc')
            ->first();

        if ($nextFaq) {
            $tempOrder = $this->order_index;
            $this->update(['order_index' => $nextFaq->order_index]);
            $nextFaq->update(['order_index' => $tempOrder]);
        }
    }

    /**
     * Obtient le prochain ordre disponible pour une catégorie
     */
    public static function getNextOrderForCategory(string $category): int
    {
        return static::where('category', $category)->max('order_index') + 1;
    }

    /**
     * Scope pour les FAQs publiées
     */
    public function scopePublished(Builder $query): Builder
    {
        return $query->where('is_published', true);
    }

    /**
     * Scope pour les brouillons
     */
    public function scopeDraft(Builder $query): Builder
    {
        return $query->where('is_published', false);
    }

    /**
     * Scope par catégorie
     */
    public function scopeByCategory(Builder $query, string $category): Builder
    {
        return $query->where('category', $category);
    }

    /**
     * Scope ordonné par index d'ordre
     */
    public function scopeOrdered(Builder $query): Builder
    {
        return $query->orderBy('order_index', 'asc');
    }

    /**
     * Recherche dans les questions et réponses
     */
    public function scopeSearch(Builder $query, string $search, string $language = 'fr'): Builder
    {
        return $query->where(function ($q) use ($search, $language) {
            $q->whereRaw("JSON_UNQUOTE(JSON_EXTRACT(question, '$.{$language}')) LIKE ?", ["%{$search}%"])
              ->orWhereRaw("JSON_UNQUOTE(JSON_EXTRACT(answer, '$.{$language}')) LIKE ?", ["%{$search}%"]);
        });
    }

    /**
     * Scope pour les catégories les plus courantes
     */
    public function scopePopularCategories(Builder $query): Builder
    {
        return $query->whereIn('category', ['general', 'reporting', 'safety', 'legal']);
    }

    /**
     * Obtient la description de la catégorie
     */
    public function getCategoryDescriptionAttribute(): string
    {
        return match($this->category) {
            'general' => 'Général',
            'reporting' => 'Signalement',
            'safety' => 'Sécurité',
            'legal' => 'Juridique',
            'services' => 'Services',
            'privacy' => 'Confidentialité',
            'emergency' => 'Urgence',
            'children' => 'Protection des enfants',
            'support' => 'Soutien',
            default => $this->category
        };
    }

    /**
     * Obtient les statistiques par catégorie
     */
    public static function getCategoryStats(): array
    {
        return static::published()
            ->selectRaw('category, COUNT(*) as count')
            ->groupBy('category')
            ->orderBy('count', 'desc')
            ->pluck('count', 'category')
            ->toArray();
    }

    /**
     * Obtient les FAQs les plus consultées (basé sur l'ordre)
     */
    public static function getMostConsulted(int $limit = 10): \Illuminate\Database\Eloquent\Collection
    {
        return static::published()
            ->orderBy('order_index', 'asc')
            ->limit($limit)
            ->get();
    }

    /**
     * Boot du modèle pour définir automatiquement l'ordre
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($faq) {
            if (is_null($faq->order_index)) {
                $faq->order_index = static::getNextOrderForCategory($faq->category);
            }
        });

        static::deleting(function ($faq) {
            // Réorganiser les ordres après suppression
            static::where('category', $faq->category)
                ->where('order_index', '>', $faq->order_index)
                ->decrement('order_index');
        });
    }
}