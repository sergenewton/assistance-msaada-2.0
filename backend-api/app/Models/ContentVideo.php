<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;

class ContentVideo extends Model
{
    use HasUuids;

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'title',
        'description',
        'video_url',
        'thumbnail_url',
        'duration',
        'category',
        'views_count',
        'is_published',
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'title' => 'array',
        'description' => 'array',
        'duration' => 'integer',
        'views_count' => 'integer',
        'is_published' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Obtient le titre dans une langue spécifique
     */
    public function getTitleInLanguage(string $language = 'fr'): string
    {
        return $this->title[$language] ?? $this->title['fr'] ?? '';
    }

    /**
     * Obtient la description dans une langue spécifique
     */
    public function getDescriptionInLanguage(string $language = 'fr'): string
    {
        return $this->description[$language] ?? $this->description['fr'] ?? '';
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
     * Définit la description dans une langue spécifique
     */
    public function setDescriptionInLanguage(string $language, string $description): void
    {
        $descriptions = $this->description ?? [];
        $descriptions[$language] = $description;
        $this->update(['description' => $descriptions]);
    }

    /**
     * Obtient les langues disponibles pour cette vidéo
     */
    public function getAvailableLanguagesAttribute(): array
    {
        $titleLanguages = array_keys($this->title ?? []);
        $descriptionLanguages = array_keys($this->description ?? []);
        
        return array_unique(array_merge($titleLanguages, $descriptionLanguages));
    }

    /**
     * Vérifie si la vidéo est disponible dans une langue
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
     * Publie la vidéo
     */
    public function publish(): void
    {
        $this->update(['is_published' => true]);
    }

    /**
     * Dépublie la vidéo
     */
    public function unpublish(): void
    {
        $this->update(['is_published' => false]);
    }

    /**
     * Obtient la durée formatée (HH:MM:SS)
     */
    public function getFormattedDurationAttribute(): string
    {
        if (!$this->duration) {
            return '00:00';
        }

        $hours = intval($this->duration / 3600);
        $minutes = intval(($this->duration % 3600) / 60);
        $seconds = $this->duration % 60;

        if ($hours > 0) {
            return sprintf('%02d:%02d:%02d', $hours, $minutes, $seconds);
        }

        return sprintf('%02d:%02d', $minutes, $seconds);
    }

    /**
     * Vérifie si la vidéo est courte (< 5 minutes)
     */
    public function isShortVideo(): bool
    {
        return $this->duration && $this->duration < 300; // 5 minutes = 300 secondes
    }

    /**
     * Vérifie si la vidéo est longue (> 30 minutes)
     */
    public function isLongVideo(): bool
    {
        return $this->duration && $this->duration > 1800; // 30 minutes = 1800 secondes
    }

    /**
     * Obtient l'URL de la miniature ou une miniature par défaut
     */
    public function getThumbnailUrlAttribute($value): string
    {
        return $value ?: asset('images/default-video-thumbnail.jpg');
    }

    /**
     * Détecte le type de plateforme vidéo
     */
    public function getVideoPlatformAttribute(): string
    {
        $url = $this->video_url;

        if (str_contains($url, 'youtube.com') || str_contains($url, 'youtu.be')) {
            return 'youtube';
        } elseif (str_contains($url, 'vimeo.com')) {
            return 'vimeo';
        } elseif (str_contains($url, 'dailymotion.com')) {
            return 'dailymotion';
        }

        return 'other';
    }

    /**
     * Obtient l'ID de la vidéo pour les plateformes connues
     */
    public function getVideoIdAttribute(): ?string
    {
        $url = $this->video_url;
        $platform = $this->video_platform;

        return match($platform) {
            'youtube' => $this->extractYouTubeId($url),
            'vimeo' => $this->extractVimeoId($url),
            'dailymotion' => $this->extractDailymotionId($url),
            default => null
        };
    }

    /**
     * Extrait l'ID YouTube d'une URL
     */
    private function extractYouTubeId(string $url): ?string
    {
        preg_match('/(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]+)/', $url, $matches);
        return $matches[1] ?? null;
    }

    /**
     * Extrait l'ID Vimeo d'une URL
     */
    private function extractVimeoId(string $url): ?string
    {
        preg_match('/vimeo\.com\/(\d+)/', $url, $matches);
        return $matches[1] ?? null;
    }

    /**
     * Extrait l'ID Dailymotion d'une URL
     */
    private function extractDailymotionId(string $url): ?string
    {
        preg_match('/dailymotion\.com\/video\/([a-zA-Z0-9_-]+)/', $url, $matches);
        return $matches[1] ?? null;
    }

    /**
     * Scope pour les vidéos publiées
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
     * Scope pour les vidéos populaires
     */
    public function scopePopular(Builder $query, int $minViews = 50): Builder
    {
        return $query->where('views_count', '>=', $minViews);
    }

    /**
     * Scope pour les vidéos courtes
     */
    public function scopeShort(Builder $query): Builder
    {
        return $query->where('duration', '<', 300);
    }

    /**
     * Scope pour les vidéos longues
     */
    public function scopeLong(Builder $query): Builder
    {
        return $query->where('duration', '>', 1800);
    }

    /**
     * Scope par durée
     */
    public function scopeByDuration(Builder $query, int $minDuration, int $maxDuration): Builder
    {
        return $query->whereBetween('duration', [$minDuration, $maxDuration]);
    }

    /**
     * Scope ordonné par popularité
     */
    public function scopeOrderByPopularity(Builder $query): Builder
    {
        return $query->orderBy('views_count', 'desc');
    }

    /**
     * Scope ordonné par date de création
     */
    public function scopeOrderByNewest(Builder $query): Builder
    {
        return $query->orderBy('created_at', 'desc');
    }

    /**
     * Recherche dans le titre et la description
     */
    public function scopeSearch(Builder $query, string $search, string $language = 'fr'): Builder
    {
        return $query->where(function ($q) use ($search, $language) {
            $q->whereRaw("JSON_UNQUOTE(JSON_EXTRACT(title, '$.{$language}')) LIKE ?", ["%{$search}%"])
              ->orWhereRaw("JSON_UNQUOTE(JSON_EXTRACT(description, '$.{$language}')) LIKE ?", ["%{$search}%"]);
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
}