<?php

namespace App\Traits;

use Illuminate\Support\Facades\Crypt;
use Illuminate\Contracts\Encryption\DecryptException;

trait HasEncryptedAttributes
{
    /**
     * Attributs qui doivent être chiffrés
     */
    // Default list in case the model doesn't define $encrypted
    protected $encryptedAttributes = [];

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
        foreach ($this->encryptedAttributesList() as $attribute) {
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
        foreach ($this->encryptedAttributesList() as $attribute) {
            if (isset($this->attributes[$attribute]) && !empty($this->attributes[$attribute])) {
                $this->attributes[$attribute] = $this->tryDecrypt($this->attributes[$attribute]);
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
            return $this->tryDecrypt($this->attributes[$key]);
        }
        return null;
    }

    /**
     * Try to decrypt a value using decryptString first, then fallback to decrypt
     * to support legacy data encrypted via helper encrypt().
     */
    protected function tryDecrypt($value)
    {
        try {
            return Crypt::decryptString($value);
        } catch (DecryptException $e) {
            try {
                // Fallback for payloads created by encrypt() helper
                return Crypt::decrypt($value);
            } catch (DecryptException $e2) {
                // Return original if not decryptable
                return $value;
            }
        }
    }

    /**
     * Resolve which attributes should be encrypted.
     * Prefer model-defined $encrypted when available.
     */
    protected function encryptedAttributesList(): array
    {
        if (property_exists($this, 'encrypted') && is_array($this->encrypted)) {
            return $this->encrypted;
        }
        return $this->encryptedAttributes;
    }
}