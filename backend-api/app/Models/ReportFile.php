<?php

namespace App\Models;

use App\Traits\HasEncryptedAttributes;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

class ReportFile extends Model
{
    use HasUuids, HasEncryptedAttributes;

    /**
     * Attributs chiffrés
     */
    protected $encrypted = [
        'file_path',
        'file_name',
    ];

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'report_id',
        'file_type',
        'file_path',
        'file_name',
        'file_size',
        'mime_type',
        'uploaded_by',
    ];

    /**
     * The attributes that should be hidden for serialization.
     */
    protected $hidden = [
        'file_path',
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'file_size' => 'integer',
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
     * Relation avec l'utilisateur qui a uploadé le fichier
     */
    public function uploader(): BelongsTo
    {
        return $this->belongsTo(User::class, 'uploaded_by');
    }

    /**
     * Obtient l'URL sécurisée du fichier
     */
    public function getSecureUrlAttribute(): string
    {
        // Générer une URL signée temporaire pour accéder au fichier
        return Storage::disk('secure')->temporaryUrl(
            $this->file_path,
            now()->addMinutes(30)
        );
    }

    /**
     * Obtient la taille formatée du fichier
     */
    public function getFormattedSizeAttribute(): string
    {
        $bytes = $this->file_size;
        
        if ($bytes >= 1073741824) {
            $bytes = number_format($bytes / 1073741824, 2) . ' GB';
        } elseif ($bytes >= 1048576) {
            $bytes = number_format($bytes / 1048576, 2) . ' MB';
        } elseif ($bytes >= 1024) {
            $bytes = number_format($bytes / 1024, 2) . ' KB';
        } elseif ($bytes > 1) {
            $bytes = $bytes . ' bytes';
        } elseif ($bytes == 1) {
            $bytes = $bytes . ' byte';
        } else {
            $bytes = '0 bytes';
        }

        return $bytes;
    }

    /**
     * Vérifie si le fichier est une image
     */
    public function isImage(): bool
    {
        return $this->file_type === 'photo' || 
               str_starts_with($this->mime_type, 'image/');
    }

    /**
     * Vérifie si le fichier est un document
     */
    public function isDocument(): bool
    {
        return $this->file_type === 'document' || 
               in_array($this->mime_type, [
                   'application/pdf',
                   'application/msword',
                   'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                   'text/plain'
               ]);
    }

    /**
     * Vérifie si le fichier est un audio
     */
    public function isAudio(): bool
    {
        return $this->file_type === 'audio' || 
               str_starts_with($this->mime_type, 'audio/');
    }

    /**
     * Vérifie si le fichier est une vidéo
     */
    public function isVideo(): bool
    {
        return $this->file_type === 'video' || 
               str_starts_with($this->mime_type, 'video/');
    }

    /**
     * Supprime le fichier du stockage sécurisé
     */
    public function deleteFile(): bool
    {
        if (Storage::disk('secure')->exists($this->file_path)) {
            return Storage::disk('secure')->delete($this->file_path);
        }
        return true;
    }

    /**
     * Scope par type de fichier
     */
    public function scopeByType($query, string $type)
    {
        return $query->where('file_type', $type);
    }

    /**
     * Scope pour les images
     */
    public function scopeImages($query)
    {
        return $query->where('file_type', 'photo');
    }

    /**
     * Scope pour les documents
     */
    public function scopeDocuments($query)
    {
        return $query->where('file_type', 'document');
    }

    /**
     * Scope pour les fichiers audio
     */
    public function scopeAudio($query)
    {
        return $query->where('file_type', 'audio');
    }

    /**
     * Scope pour les fichiers vidéo
     */
    public function scopeVideo($query)
    {
        return $query->where('file_type', 'video');
    }

    /**
     * Scope pour les fichiers récents
     */
    public function scopeRecent($query, int $days = 30)
    {
        return $query->where('created_at', '>=', now()->subDays($days));
    }

    /**
     * Mutator pour le chemin de fichier chiffré
     */
    public function setFilePathAttribute($value)
    {
        $this->setEncryptedAttribute('file_path', $value);
    }

    /**
     * Accessor pour le chemin de fichier déchiffré
     */
    public function getFilePathAttribute()
    {
        return $this->getEncryptedAttribute('file_path');
    }

    /**
     * Mutator pour le nom de fichier chiffré
     */
    public function setFileNameAttribute($value)
    {
        $this->setEncryptedAttribute('file_name', $value);
    }

    /**
     * Accessor pour le nom de fichier déchiffré
     */
    public function getFileNameAttribute()
    {
        return $this->getEncryptedAttribute('file_name');
    }

    /**
     * Boot du modèle pour supprimer le fichier lors de la suppression du modèle
     */
    protected static function boot()
    {
        parent::boot();

        static::deleting(function ($reportFile) {
            $reportFile->deleteFile();
        });
    }
}