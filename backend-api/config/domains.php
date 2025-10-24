<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Domain Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration des domaines de l'application selon les principes DDD.
    | Chaque domaine a ses propres règles, services et repositories.
    |
    */

    'domains' => [
        'auth' => [
            'name' => 'Authentication',
            'namespace' => 'App\\Domain\\Auth',
            'entities' => [
                'User',
                'Role',
                'Permission',
            ],
            'repositories' => [
                'UserRepositoryInterface' => 'App\\Infrastructure\\Persistence\\Eloquent\\Repositories\\UserRepository',
                'RoleRepositoryInterface' => 'App\\Infrastructure\\Persistence\\Eloquent\\Repositories\\RoleRepository',
            ],
            'services' => [
                'AuthenticationService',
                'PasswordService',
                'EmailVerificationService',
            ],
            'events' => [
                'UserRegistered',
                'UserLoggedIn',
                'PasswordReset',
                'EmailVerified',
            ],
        ],
        
        'reports' => [
            'name' => 'Reports Management',
            'namespace' => 'App\\Domain\\Reports',
            'entities' => [
                'Report',
                'ReportStatus',
                'ReportCategory',
                'Attachment',
            ],
            'repositories' => [
                'ReportRepositoryInterface' => 'App\\Infrastructure\\Persistence\\Eloquent\\Repositories\\ReportRepository',
                'ReportStatusRepositoryInterface' => 'App\\Infrastructure\\Persistence\\Eloquent\\Repositories\\ReportStatusRepository',
            ],
            'services' => [
                'ReportService',
                'ReportStatusService',
                'ReportAnalyticsService',
            ],
            'events' => [
                'ReportCreated',
                'ReportUpdated',
                'ReportStatusChanged',
                'ReportDeleted',
            ],
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Auto-Discovery Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration pour la découverte automatique des composants DDD
    |
    */

    'auto_discovery' => [
        'enabled' => true,
        'scan_paths' => [
            'app/Domain',
            'app/Application',
            'app/Infrastructure',
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Event Bus Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration du bus d'événements pour la communication entre domaines
    |
    */

    'event_bus' => [
        'default_dispatcher' => 'sync',
        'cross_domain_events' => true,
        'event_store' => [
            'enabled' => false,
            'driver' => 'database',
        ],
    ],

];
