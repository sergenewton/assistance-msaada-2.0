<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Use Cases Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration des cas d'usage (Use Cases) de l'application.
    | Chaque cas d'usage représente une action métier spécifique.
    |
    */

    'use_cases' => [
        
        'auth' => [
            'register_user' => [
                'handler' => 'App\\Application\\Auth\\Handlers\\RegisterUserHandler',
                'validation' => [
                    'email' => 'required|email|unique:users',
                    'password' => 'required|min:8',
                    'name' => 'required|string|max:255',
                ],
                'middleware' => ['throttle:5,1'],
            ],
            
            'login_user' => [
                'handler' => 'App\\Application\\Auth\\Handlers\\LoginUserHandler',
                'validation' => [
                    'email' => 'required|email',
                    'password' => 'required',
                ],
                'middleware' => ['throttle:10,1'],
            ],
            
            'reset_password' => [
                'handler' => 'App\\Application\\Auth\\Handlers\\ResetPasswordHandler',
                'validation' => [
                    'email' => 'required|email|exists:users',
                ],
                'middleware' => ['throttle:3,1'],
            ],
        ],
        
        'reports' => [
            'create_report' => [
                'handler' => 'App\\Application\\Reports\\Handlers\\CreateReportHandler',
                'validation' => [
                    'title' => 'required|string|max:255',
                    'description' => 'required|string',
                    'category_id' => 'required|exists:report_categories,id',
                ],
                'middleware' => ['auth:sanctum'],
            ],
            
            'update_report_status' => [
                'handler' => 'App\\Application\\Reports\\Handlers\\UpdateReportStatusHandler',
                'validation' => [
                    'status' => 'required|in:pending,in_progress,resolved,closed',
                    'comment' => 'nullable|string',
                ],
                'middleware' => ['auth:sanctum', 'role:admin'],
            ],
            
            'delete_report' => [
                'handler' => 'App\\Application\\Reports\\Handlers\\DeleteReportHandler',
                'validation' => [],
                'middleware' => ['auth:sanctum', 'can:delete,report'],
            ],
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Command Bus Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration du bus de commandes pour CQRS
    |
    */

    'command_bus' => [
        'default_driver' => 'sync',
        'middleware' => [
            'validation',
            'authorization',
            'logging',
        ],
        'retry' => [
            'attempts' => 3,
            'delay' => 1000, // millisecondes
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Query Bus Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration du bus de requêtes pour CQRS
    |
    */

    'query_bus' => [
        'default_driver' => 'sync',
        'cache' => [
            'enabled' => true,
            'ttl' => 3600,
        ],
        'middleware' => [
            'authorization',
            'caching',
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Event Sourcing Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration pour l'Event Sourcing (optionnel)
    |
    */

    'event_sourcing' => [
        'enabled' => false,
        'store' => [
            'driver' => 'database',
            'table' => 'event_store',
        ],
        'snapshots' => [
            'enabled' => false,
            'frequency' => 10, // Tous les 10 événements
        ],
    ],

];