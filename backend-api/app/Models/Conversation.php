<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Builder;

class Conversation extends Model
{
    use HasUuids;

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'report_id',
        'aps_id',
        'survivor_id',
        'is_encrypted',
        'encryption_key_id',
        'last_message_at',
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'is_encrypted' => 'boolean',
        'last_message_at' => 'datetime',
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
     * Relation avec l'APS
     */
    public function aps(): BelongsTo
    {
        return $this->belongsTo(User::class, 'aps_id');
    }

    /**
     * Relation avec la survivante
     */
    public function survivor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'survivor_id');
    }

    /**
     * Messages de cette conversation
     */
    public function messages(): HasMany
    {
        return $this->hasMany(Message::class)->orderBy('created_at', 'asc');
    }

    /**
     * Messages non lus
     */
    public function unreadMessages(): HasMany
    {
        return $this->hasMany(Message::class)->where('is_read', false);
    }

    /**
     * Dernier message
     */
    public function lastMessage()
    {
        return $this->hasOne(Message::class)->latestOfMany();
    }

    /**
     * Messages non lus pour un utilisateur spécifique
     */
    public function unreadMessagesForUser(User $user): HasMany
    {
        return $this->hasMany(Message::class)
                   ->where('is_read', false)
                   ->where('sender_id', '!=', $user->id);
    }

    /**
     * Marque tous les messages comme lus pour un utilisateur
     */
    public function markAsReadForUser(User $user): void
    {
        $this->messages()
             ->where('sender_id', '!=', $user->id)
             ->where('is_read', false)
             ->update([
                 'is_read' => true,
                 'read_at' => now()
             ]);
    }

    /**
     * Envoie un message dans cette conversation
     */
    public function sendMessage(User $sender, string $content, string $type = 'text', ?string $filePath = null): Message
    {
        $message = $this->messages()->create([
            'sender_id' => $sender->id,
            'message_type' => $type,
            'content' => $content,
            'file_path' => $filePath,
        ]);

        // Mettre à jour le timestamp du dernier message
        $this->update(['last_message_at' => now()]);

        return $message;
    }

    /**
     * Vérifie si un utilisateur fait partie de cette conversation
     */
    public function includesUser(User $user): bool
    {
        return $user->id === $this->aps_id || $user->id === $this->survivor_id;
    }

    /**
     * Obtient l'autre participant de la conversation
     */
    public function getOtherParticipant(User $user): User
    {
        if ($user->id === $this->aps_id) {
            return $this->survivor;
        } elseif ($user->id === $this->survivor_id) {
            return $this->aps;
        }
        
        throw new \InvalidArgumentException('User is not a participant in this conversation');
    }

    /**
     * Compte les messages non lus pour un utilisateur
     */
    public function countUnreadMessagesForUser(User $user): int
    {
        return $this->unreadMessagesForUser($user)->count();
    }

    /**
     * Vérifie si la conversation est active (messages récents)
     */
    public function isActive(int $days = 7): bool
    {
        return $this->last_message_at && 
               $this->last_message_at >= now()->subDays($days);
    }

    /**
     * Archive automatiquement les anciens messages
     */
    public function archiveOldMessages(int $days = 90): int
    {
        return $this->messages()
                   ->where('created_at', '<', now()->subDays($days))
                   ->whereNotNull('auto_delete_at')
                   ->where('auto_delete_at', '<', now())
                   ->delete();
    }

    /**
     * Scope pour les conversations actives
     */
    public function scopeActive(Builder $query, int $days = 7): Builder
    {
        return $query->where('last_message_at', '>=', now()->subDays($days));
    }

    /**
     * Scope pour les conversations d'un utilisateur
     */
    public function scopeForUser(Builder $query, User $user): Builder
    {
        return $query->where(function ($q) use ($user) {
            $q->where('aps_id', $user->id)
              ->orWhere('survivor_id', $user->id);
        });
    }

    /**
     * Scope pour les conversations d'un APS
     */
    public function scopeForAPS(Builder $query, User $aps): Builder
    {
        return $query->where('aps_id', $aps->id);
    }

    /**
     * Scope pour les conversations d'une survivante
     */
    public function scopeForSurvivor(Builder $query, User $survivor): Builder
    {
        return $query->where('survivor_id', $survivor->id);
    }

    /**
     * Scope avec messages non lus
     */
    public function scopeWithUnreadMessages(Builder $query, User $user): Builder
    {
        return $query->whereHas('messages', function ($q) use ($user) {
            $q->where('is_read', false)
              ->where('sender_id', '!=', $user->id);
        });
    }

    /**
     * Scope ordonné par dernière activité
     */
    public function scopeOrderedByLastActivity(Builder $query): Builder
    {
        return $query->orderBy('last_message_at', 'desc');
    }
}