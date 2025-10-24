<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Str;

class ContentArticle extends Model
{
    use HasUuids;

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'category',
        'title',
        'slug',
        'content',
        'image_url',
        'author_id',
        'views_count',
        'is_published',
        'published_at',
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'title' => 'array',
        'content' => 'array',
        'views_count' => 'integer',
        'is_published' => 'boolean',
        'published_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Relation avec l'auteur
     */
    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'author_id');
    }

    /**
     * Obtient le titre dans une langue spécifique
     */
    public function getTitleInLanguage(string $language = 'fr'): string
    {
        return $this->title[$language] ?? $this->title['fr'] ?? '';
    }

    /**
     * Obtient le contenu dans une langue spécifique
     */
    public function getContentInLanguage(string $language = 'fr'): string
    {
        return $this->content[$language] ?? $this->content['fr'] ?? '';
    }

    /**
     * Définit le titre dans une langue spécifique
     */
    public function setTitleInLanguage(string $language, string $title): void
    {
        $titles = $this->title ?? [];
        $titles[$language] = $title;
        $this->update(['title' => $titles]);
    }

    /**
     * Définit le contenu dans une langue spécifique
     */
    public function setContentInLanguage(string $language, string $content): void
    {
        $contents = $this->content ?? [];
        $contents[$language] = $content;
        $this->update(['content' => $contents]);
    }

    /**
     * Obtient les langues disponibles pour cet article
     */
    public function getAvailableLanguagesAttribute(): array
    {
        $titleLanguages = array_keys($this->title ?? []);
        $contentLanguages = array_keys($this->content ?? []);
        
        return array_unique(array_merge($titleLanguages, $contentLanguages));
    }

    /**
     * Vérifie si l'article est disponible dans une langue
     */
    public function isAvailableInLanguage(string $language): bool
    {
        return in_array($language, $this->available_languages);
    }

    /**
     * Incrémente le compteur de vues
     */
    public function incrementViews(): void
    {
        $this->increment('views_count');
    }

    /**
     * Publie l'article
     */
    public function publish(): void
    {
        $this->update([
            'is_published' => true,
            'published_at' => now(),
        ]);
    }

    /**
     * Dépublie l'article
     */
    public function unpublish(): void
    {
        $this->update([
            'is_published' => false,
            'published_at' => null,
        ]);
    }

    /**
     * Génère automatiquement un slug basé sur le titre français
     */
    public function generateSlug(): string
    {
        $title = $this->getTitleInLanguage('fr');
        $baseSlug = Str::slug($title);
        $slug = $baseSlug;
        $counter = 1;

        while (static::where('slug', $slug)->where('id', '!=', $this->id)->exists()) {
            $slug = $baseSlug . '-' . $counter;
            $counter++;
        }

        return $slug;
    }

    /**
     * Obtient un extrait du contenu
     */
    public function getExcerptAttribute(int $length = 200): string
    {
        $content = $this->getContentInLanguage();
        return Str::limit(strip_tags($content), $length);
    }

    /**
     * Obtient l'URL de l'article
     */
    public function getUrlAttribute(): string
    {
        return route('articles.show', $this->slug);
    }

    /**
     * Scope pour les articles publiés
     */
    public function scopePublished(Builder $query): Builder
    {
        return $query->where('is_published', true)
                    ->whereNotNull('published_at');
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
     * Scope par auteur
     */
    public function scopeByAuthor(Builder $query, User $author): Builder
    {
        return $query->where('author_id', $author->id);
    }

    /**
     * Scope pour les articles populaires
     */
    public function scopePopular(Builder $query, int $minViews = 100): Builder
    {
        return $query->where('views_count', '>=', $minViews);
    }

    /**
     * Scope pour les articles récents
     */
    public function scopeRecent(Builder $query, int $days = 30): Builder
    {
        return $query->where('published_at', '>=', now()->subDays($days));
    }

    /**
     * Scope ordonné par popularité
     */
    public function scopeOrderByPopularity(Builder $query): Builder
    {
        return $query->orderBy('views_count', 'desc');
    }

    /**
     * Scope ordonné par date de publication
     */
    public function scopeOrderByPublished(Builder $query): Builder
    {
        return $query->orderBy('published_at', 'desc');
    }

    /**
     * Recherche dans le titre et le contenu
     */
    public function scopeSearch(Builder $query, string $search, string $language = 'fr'): Builder
    {
        return $query->where(function ($q) use ($search, $language) {
            $q->whereRaw("JSON_UNQUOTE(JSON_EXTRACT(title, '$.{$language}')) LIKE ?", ["%{$search}%"])
              ->orWhereRaw("JSON_UNQUOTE(JSON_EXTRACT(content, '$.{$language}')) LIKE ?", ["%{$search}%"]);
        });
    }

    /**
     * Obtient la description de la catégorie
     */
    public function getCategoryDescriptionAttribute(): string
    {
        return match($this->category) {
            'prevention' => 'Prévention',
            'rights_awareness' => 'Sensibilisation aux droits',
            'support_services' => 'Services d\'assistance',
            'legal_information' => 'Informations juridiques',
            'health_safety' => 'Santé et sécurité',
            'empowerment' => 'Autonomisation',
            'child_protection' => 'Protection de l\'enfant',
            'emergency_procedures' => 'Procédures d\'urgence',
            default => $this->category
        };
    }

    /**
     * Boot du modèle pour générer automatiquement le slug
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($article) {
            if (empty($article->slug)) {
                $article->slug = $article->generateSlug();
            }
        });

        static::updating(function ($article) {
            if ($article->isDirty('title') && empty($article->slug)) {
                $article->slug = $article->generateSlug();
            }
        });
    }
}