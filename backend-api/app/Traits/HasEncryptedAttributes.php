<?php

namespace App\Traits;

use Illuminate\Support\Facades\Crypt;
use Illuminate\Contracts\Encryption\DecryptException;

trait HasEncryptedAttributes
{
    /**
     * Obtient les attributs qui doivent être chiffrés
     * Cette méthode doit être définie dans la classe qui utilise le trait
     */
    protected function getEncryptedAttributes()
    {
        return property_exists($this, 'encrypted') ? $this->encrypted : [];
    }

    /**
     * Boot du trait
     */
    public static function bootHasEncryptedAttributes()
    {
        static::saving(function ($model) {
            $model->encryptAttributes();
        });

        static::retrieved(function ($model) {
            $model->decryptAttributes();
        });
    }

    /**
     * Chiffre les attributs spécifiés
     */
    protected function encryptAttributes()
    {
        foreach ($this->getEncryptedAttributes() as $attribute) {
            if (isset($this->attributes[$attribute]) && !empty($this->attributes[$attribute])) {
                $this->attributes[$attribute] = Crypt::encryptString($this->attributes[$attribute]);
            }
        }
    }

    /**
     * Déchiffre les attributs spécifiés
     */
    protected function decryptAttributes()
    {
        foreach ($this->getEncryptedAttributes() as $attribute) {
            if (isset($this->attributes[$attribute]) && !empty($this->attributes[$attribute])) {
                try {
                    $this->attributes[$attribute] = Crypt::decryptString($this->attributes[$attribute]);
                } catch (DecryptException $e) {
                    // Si le déchiffrement échoue, on garde la valeur originale
                    // Cela peut arriver si la donnée n'était pas encore chiffrée
                }
            }
        }
    }

    /**
     * Accessor pour chiffrement à la volée
     */
    public function setEncryptedAttribute($key, $value)
    {
        if (!empty($value)) {
            $this->attributes[$key] = Crypt::encryptString($value);
        }
    }

    /**
     * Mutator pour déchiffrement à la volée
     */
    public function getEncryptedAttribute($key)
    {
        if (isset($this->attributes[$key]) && !empty($this->attributes[$key])) {
            try {
                return Crypt::decryptString($this->attributes[$key]);
            } catch (DecryptException $e) {
                return $this->attributes[$key];
            }
        }
        return null;
    }
}