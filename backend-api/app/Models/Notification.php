<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Builder;

class Notification extends Model
{
    use HasUuids;

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'user_id',
        'type',
        'title',
        'body',
        'data',
        'channels_sent',
        'is_read',
        'read_at',
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'data' => 'array',
        'channels_sent' => 'array',
        'is_read' => 'boolean',
        'read_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Relation avec l'utilisateur destinataire
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Marque la notification comme lue
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
     * Marque la notification comme non lue
     */
    public function markAsUnread(): void
    {
        $this->update([
            'is_read' => false,
            'read_at' => null
        ]);
    }

    /**
     * Vérifie si la notification a été envoyée via un canal spécifique
     */
    public function wasSentVia(string $channel): bool
    {
        return in_array($channel, $this->channels_sent ?? []);
    }

    /**
     * Ajoute un canal d'envoi
     */
    public function addSentChannel(string $channel): void
    {
        $channels = $this->channels_sent ?? [];
        if (!in_array($channel, $channels)) {
            $channels[] = $channel;
            $this->update(['channels_sent' => $channels]);
        }
    }

    /**
     * Obtient une donnée contextuelle spécifique
     */
    public function getData(string $key, $default = null)
    {
        return data_get($this->data, $key, $default);
    }

    /**
     * Définit une donnée contextuelle
     */
    public function setData(string $key, $value): void
    {
        $data = $this->data ?? [];
        data_set($data, $key, $value);
        $this->update(['data' => $data]);
    }

    /**
     * Scope pour les notifications non lues
     */
    public function scopeUnread(Builder $query): Builder
    {
        return $query->where('is_read', false);
    }

    /**
     * Scope pour les notifications lues
     */
    public function scopeRead(Builder $query): Builder
    {
        return $query->where('is_read', true);
    }

    /**
     * Scope par type de notification
     */
    public function scopeByType(Builder $query, string $type): Builder
    {
        return $query->where('type', $type);
    }

    /**
     * Scope pour les notifications récentes
     */
    public function scopeRecent(Builder $query, int $days = 7): Builder
    {
        return $query->where('created_at', '>=', now()->subDays($days));
    }

    /**
     * Scope pour les notifications d'alerte
     */
    public function scopeAlerts(Builder $query): Builder
    {
        return $query->where('type', 'alert');
    }

    /**
     * Scope pour les notifications de nouveaux cas
     */
    public function scopeNewCases(Builder $query): Builder
    {
        return $query->where('type', 'new_case');
    }

    /**
     * Scope pour les notifications d'assignation
     */
    public function scopeAssignments(Builder $query): Builder
    {
        return $query->where('type', 'assignment');
    }

    /**
     * Scope ordonné par date de création (plus récent en premier)
     */
    public function scopeLatest(Builder $query): Builder
    {
        return $query->orderBy('created_at', 'desc');
    }

    /**
     * Méthode statique pour créer une notification d'alerte
     */
    public static function createAlert(User $user, string $title, string $body, array $data = []): self
    {
        return static::create([
            'user_id' => $user->id,
            'type' => 'alert',
            'title' => $title,
            'body' => $body,
            'data' => $data,
        ]);
    }

    /**
     * Méthode statique pour créer une notification de nouveau cas
     */
    public static function createNewCase(User $user, Report $report): self
    {
        return static::create([
            'user_id' => $user->id,
            'type' => 'new_case',
            'title' => 'Nouveau signalement',
            'body' => "Un nouveau signalement #{$report->report_number} a été créé",
            'data' => [
                'report_id' => $report->id,
                'urgency_level' => $report->urgency_level,
                'violence_type' => $report->violence_type,
            ],
        ]);
    }

    /**
     * Méthode statique pour créer une notification d'assignation
     */
    public static function createAssignment(User $aps, Report $report): self
    {
        return static::create([
            'user_id' => $aps->id,
            'type' => 'assignment',
            'title' => 'Cas assigné',
            'body' => "Le signalement #{$report->report_number} vous a été assigné",
            'data' => [
                'report_id' => $report->id,
                'urgency_level' => $report->urgency_level,
                'assigned_at' => now()->toISOString(),
            ],
        ]);
    }

    /**
     * Méthode statique pour créer une notification de mise à jour
     */
    public static function createUpdate(User $user, string $title, string $body, array $data = []): self
    {
        return static::create([
            'user_id' => $user->id,
            'type' => 'update',
            'title' => $title,
            'body' => $body,
            'data' => $data,
        ]);
    }

    /**
     * Méthode statique pour créer une notification de rappel
     */
    public static function createReminder(User $user, string $title, string $body, array $data = []): self
    {
        return static::create([
            'user_id' => $user->id,
            'type' => 'reminder',
            'title' => $title,
            'body' => $body,
            'data' => $data,
        ]);
    }

    /**
     * Obtient la description du type de notification
     */
    public function getTypeDescriptionAttribute(): string
    {
        return match($this->type) {
            'new_case' => 'Nouveau cas',
            'assignment' => 'Assignation',
            'update' => 'Mise à jour',
            'reminder' => 'Rappel',
            'alert' => 'Alerte',
            'referral_response' => 'Réponse de référencement',
            default => $this->type
        };
    }
}