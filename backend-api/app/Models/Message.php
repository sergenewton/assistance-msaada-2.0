<?php

namespace App\Models;

use App\Traits\HasEncryptedAttributes;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Builder;

class Message extends Model
{
    use HasUuids, HasEncryptedAttributes;

    /**
     * Attributs chiffrés
     */
    protected $encrypted = [
        'content',
    ];

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'conversation_id',
        'sender_id',
        'message_type',
        'content',
        'file_path',
        'is_read',
        'read_at',
        'is_deleted_by_sender',
        'is_deleted_by_receiver',
        'auto_delete_at',
    ];

    /**
     * The attributes that should be hidden for serialization.
     */
    protected $hidden = [
        'content',
        'file_path',
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'is_read' => 'boolean',
        'is_deleted_by_sender' => 'boolean',
        'is_deleted_by_receiver' => 'boolean',
        'read_at' => 'datetime',
        'auto_delete_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Relation avec la conversation
     */
    public function conversation(): BelongsTo
    {
        return $this->belongsTo(Conversation::class);
    }

    /**
     * Relation avec l'expéditeur
     */
    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    /**
     * Marque le message comme lu
     */
    public function markAsRead(): void
    {
        if (!$this->is_read) {
            $this->update([
                'is_read' => true,
                'read_at' => now()
            ]);
        }
    }

    /**
     * Supprime le message pour l'expéditeur
     */
    public function deleteForSender(): void
    {
        $this->update(['is_deleted_by_sender' => true]);
        $this->checkForFullDeletion();
    }

    /**
     * Supprime le message pour le destinataire
     */
    public function deleteForReceiver(): void
    {
        $this->update(['is_deleted_by_receiver' => true]);
        $this->checkForFullDeletion();
    }

    /**
     * Vérifie si le message doit être complètement supprimé
     */
    private function checkForFullDeletion(): void
    {
        if ($this->is_deleted_by_sender && $this->is_deleted_by_receiver) {
            $this->delete();
        }
    }

    /**
     * Programme la suppression automatique du message
     */
    public function scheduleAutoDelete(int $hours = 24): void
    {
        $this->update([
            'auto_delete_at' => now()->addHours($hours)
        ]);
    }

    /**
     * Vérifie si le message est visible pour un utilisateur
     */
    public function isVisibleForUser(User $user): bool
    {
        if (!$this->conversation->includesUser($user)) {
            return false;
        }

        if ($user->id === $this->sender_id) {
            return !$this->is_deleted_by_sender;
        } else {
            return !$this->is_deleted_by_receiver;
        }
    }

    /**
     * Vérifie si le message contient un fichier
     */
    public function hasFile(): bool
    {
        return !empty($this->file_path);
    }

    /**
     * Vérifie si le message est une image
     */
    public function isImage(): bool
    {
        return $this->message_type === 'image';
    }

    /**
     * Vérifie si le message est un audio
     */
    public function isAudio(): bool
    {
        return $this->message_type === 'audio';
    }

    /**
     * Vérifie si le message est un document
     */
    public function isDocument(): bool
    {
        return $this->message_type === 'document';
    }

    /**
     * Vérifie si le message contient une localisation
     */
    public function isLocation(): bool
    {
        return $this->message_type === 'location';
    }

    /**
     * Obtient le contenu déchiffré sécurisé (avec permissions)
     */
    public function getSecureContentForUser(User $user): ?string
    {
        if (!$this->isVisibleForUser($user)) {
            return null;
        }

        return $this->content;
    }

    /**
     * Obtient un aperçu du message (texte tronqué)
     */
    public function getPreviewAttribute(): string
    {
        if ($this->message_type !== 'text') {
            return match($this->message_type) {
                'image' => '📷 Image',
                'audio' => '🎵 Message audio',
                'document' => '📄 Document',
                'location' => '📍 Localisation',
                default => '📎 Fichier'
            };
        }

        $content = $this->content;
        return strlen($content) > 50 ? substr($content, 0, 50) . '...' : $content;
    }

    /**
     * Scope pour les messages non supprimés
     */
    public function scopeNotDeleted(Builder $query): Builder
    {
        return $query->where(function ($q) {
            $q->where('is_deleted_by_sender', false)
              ->orWhere('is_deleted_by_receiver', false);
        });
    }

    /**
     * Scope pour les messages non lus
     */
    public function scopeUnread(Builder $query): Builder
    {
        return $query->where('is_read', false);
    }

    /**
     * Scope pour les messages d'un type spécifique
     */
    public function scopeByType(Builder $query, string $type): Builder
    {
        return $query->where('message_type', $type);
    }

    /**
     * Scope pour les messages texte uniquement
     */
    public function scopeTextOnly(Builder $query): Builder
    {
        return $query->where('message_type', 'text');
    }

    /**
     * Scope pour les messages avec fichiers
     */
    public function scopeWithFiles(Builder $query): Builder
    {
        return $query->whereNotNull('file_path');
    }

    /**
     * Scope pour les messages récents
     */
    public function scopeRecent(Builder $query, int $hours = 24): Builder
    {
        return $query->where('created_at', '>=', now()->subHours($hours));
    }

    /**
     * Scope pour les messages à supprimer automatiquement
     */
    public function scopeScheduledForDeletion(Builder $query): Builder
    {
        return $query->whereNotNull('auto_delete_at')
                    ->where('auto_delete_at', '<=', now());
    }

    /**
     * Scope pour les messages visibles pour un utilisateur
     */
    public function scopeVisibleForUser(Builder $query, User $user): Builder
    {
        return $query->whereHas('conversation', function ($q) use ($user) {
            $q->where('aps_id', $user->id)
              ->orWhere('survivor_id', $user->id);
        })->where(function ($q) use ($user) {
            $q->where(function ($subQuery) use ($user) {
                // Messages envoyés par l'utilisateur et non supprimés par lui
                $subQuery->where('sender_id', $user->id)
                         ->where('is_deleted_by_sender', false);
            })->orWhere(function ($subQuery) use ($user) {
                // Messages reçus par l'utilisateur et non supprimés par lui
                $subQuery->where('sender_id', '!=', $user->id)
                         ->where('is_deleted_by_receiver', false);
            });
        });
    }

    /**
     * Mutator pour le contenu chiffré
     */
    public function setContentAttribute($value)
    {
        $this->setEncryptedAttribute('content', $value);
    }

    /**
     * Accessor pour le contenu déchiffré
     */
    public function getContentAttribute()
    {
        return $this->getEncryptedAttribute('content');
    }

    /**
     * Boot du modèle pour la suppression automatique
     */
    protected static function boot()
    {
        parent::boot();

        // Mettre à jour le timestamp de la conversation lors de la création d'un message
        static::created(function ($message) {
            $message->conversation->update(['last_message_at' => $message->created_at]);
        });
    }
}