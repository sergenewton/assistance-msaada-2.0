<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Repository Bindings
    |--------------------------------------------------------------------------
    |
    | Ici sont définis tous les bindings entre les interfaces de repository
    | et leurs implémentations concrètes selon les principes DDD.
    |
    */

    'bindings' => [
        
        // Auth Domain Repositories
        'App\\Domain\\Auth\\Repositories\\UserRepositoryInterface' => 
            'App\\Infrastructure\\Persistence\\Eloquent\\Repositories\\UserRepository',
            
        'App\\Domain\\Auth\\Repositories\\RoleRepositoryInterface' => 
            'App\\Infrastructure\\Persistence\\Eloquent\\Repositories\\RoleRepository',
            
        'App\\Domain\\Auth\\Repositories\\PermissionRepositoryInterface' => 
            'App\\Infrastructure\\Persistence\\Eloquent\\Repositories\\PermissionRepository',

        // Reports Domain Repositories
        'App\\Domain\\Reports\\Repositories\\ReportRepositoryInterface' => 
            'App\\Infrastructure\\Persistence\\Eloquent\\Repositories\\ReportRepository',
            
        'App\\Domain\\Reports\\Repositories\\ReportStatusRepositoryInterface' => 
            'App\\Infrastructure\\Persistence\\Eloquent\\Repositories\\ReportStatusRepository',
            
        'App\\Domain\\Reports\\Repositories\\ReportCategoryRepositoryInterface' => 
            'App\\Infrastructure\\Persistence\\Eloquent\\Repositories\\ReportCategoryRepository',
            
        'App\\Domain\\Reports\\Repositories\\AttachmentRepositoryInterface' => 
            'App\\Infrastructure\\Persistence\\Eloquent\\Repositories\\AttachmentRepository',

    ],

    /*
    |--------------------------------------------------------------------------
    | Repository Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration globale des repositories
    |
    */

    'config' => [
        'cache' => [
            'enabled' => true,
            'ttl' => 3600, // 1 heure
            'prefix' => 'repo_cache',
        ],
        
        'pagination' => [
            'default_per_page' => 15,
            'max_per_page' => 100,
        ],
        
        'soft_deletes' => [
            'enabled' => true,
            'include_deleted' => false,
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Query Optimization
    |--------------------------------------------------------------------------
    |
    | Configuration pour l'optimisation des requêtes
    |
    */

    'query_optimization' => [
        'eager_loading' => [
            'enabled' => true,
            'relations' => [
                'User' => ['roles', 'permissions'],
                'Report' => ['status', 'category', 'attachments', 'author'],
            ],
        ],
        
        'query_cache' => [
            'enabled' => true,
            'ttl' => 1800, // 30 minutes
        ],
    ],

];
