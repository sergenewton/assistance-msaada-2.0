<?php

return [

    /*
    |--------------------------------------------------------------------------
    | JWT Authentication Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration spécifique pour l'authentification JWT
    | Compatible avec tymon/jwt-auth package
    |
    */

    'defaults' => [
        'guard' => 'api',
    ],

    'guards' => [
        'api' => [
            'driver' => 'jwt',
            'provider' => 'users',
        ],
        'web' => [
            'driver' => 'session',
            'provider' => 'users',
        ],
    ],

    'providers' => [
        'users' => [
            'driver' => 'eloquent',
            'model' => App\Infrastructure\Persistence\Eloquent\Models\User::class,
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | JWT Configuration
    |--------------------------------------------------------------------------
    */

    'jwt' => [
        'secret' => env('JWT_SECRET'),
        'keys' => [
            'public' => env('JWT_PUBLIC_KEY'),
            'private' => env('JWT_PRIVATE_KEY'),
            'passphrase' => env('JWT_PASSPHRASE'),
        ],
        'ttl' => env('JWT_TTL', 60),
        'refresh_ttl' => env('JWT_REFRESH_TTL', 20160),
        'algo' => env('JWT_ALGO', 'HS256'),
        'required_claims' => [
            'iss',
            'iat',
            'exp',
            'nbf',
            'sub',
            'jti',
        ],
        'persistent_claims' => [],
        'lock_subject' => true,
        'leeway' => env('JWT_LEEWAY', 0),
        'blacklist_enabled' => env('JWT_BLACKLIST_ENABLED', true),
        'blacklist_grace_period' => env('JWT_BLACKLIST_GRACE_PERIOD', 0),
        'decrypt_cookies' => false,
        'providers' => [
            'jwt' => Tymon\JWTAuth\Providers\JWT\Lcobucci::class,
            'auth' => Tymon\JWTAuth\Providers\Auth\Illuminate::class,
            'storage' => Tymon\JWTAuth\Providers\Storage\Illuminate::class,
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Sanctum Configuration
    |--------------------------------------------------------------------------
    */

    'sanctum' => [
        'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', sprintf(
            '%s%s',
            'localhost,localhost:3000,127.0.0.1,127.0.0.1:8000,::1',
            env('APP_URL') ? ','.parse_url(env('APP_URL'), PHP_URL_HOST) : ''
        ))),
        'guard' => ['web'],
        'expiration' => null,
        'middleware' => [
            'verify_csrf_token' => App\Http\Middleware\VerifyCsrfToken::class,
            'encrypt_cookies' => App\Http\Middleware\EncryptCookies::class,
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Password Reset Configuration
    |--------------------------------------------------------------------------
    */

    'passwords' => [
        'users' => [
            'provider' => 'users',
            'table' => 'password_reset_tokens',
            'expire' => 60,
            'throttle' => 60,
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Password Confirmation Timeout
    |--------------------------------------------------------------------------
    */

    'password_timeout' => 10800,

];