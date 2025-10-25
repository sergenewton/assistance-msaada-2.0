<?php

/**
 * Configuration Sentry pour Assistance Msaada 2.0
 * Monitoring des erreurs spécifique pour plateforme VBG
 */

return [

    /*
    |--------------------------------------------------------------------------
    | Sentry DSN (Data Source Name)
    |--------------------------------------------------------------------------
    |
    | DSN pour l'environnement courant. Les DSN sont différents par environnement
    | pour séparer les erreurs de dev/staging/production
    |
    */

    'dsn' => env('SENTRY_DSN'),

    /*
    |--------------------------------------------------------------------------
    | Capture Release Information
    |--------------------------------------------------------------------------
    |
    | Capture automatiquement les informations de version pour tracer les erreurs
    | par version de déploiement
    |
    */

    'release' => env('SENTRY_RELEASE', config('app.version', '1.0.0')),

    /*
    |--------------------------------------------------------------------------
    | Capture Environment
    |--------------------------------------------------------------------------
    |
    | L'environnement dans lequel l'application s'exécute
    |
    */

    'environment' => env('SENTRY_ENVIRONMENT', env('APP_ENV', 'production')),

    /*
    |--------------------------------------------------------------------------
    | Sample Rate
    |--------------------------------------------------------------------------
    |
    | Pourcentage d'événements à capturer (1.0 = 100%, 0.1 = 10%)
    | Réduit la charge en production tout en gardant une visibilité
    |
    */

    'sample_rate' => env('SENTRY_SAMPLE_RATE', 
        env('APP_ENV') === 'production' ? 0.1 : 1.0
    ),

    /*
    |--------------------------------------------------------------------------
    | Traces Sample Rate
    |--------------------------------------------------------------------------
    |
    | Pourcentage de transactions à tracer pour l'analyse de performance
    |
    */

    'traces_sample_rate' => env('SENTRY_TRACES_SAMPLE_RATE',
        env('APP_ENV') === 'production' ? 0.05 : 0.2
    ),

    /*
    |--------------------------------------------------------------------------
    | Server Name
    |--------------------------------------------------------------------------
    |
    | Nom du serveur pour identifier la source des erreurs
    |
    */

    'server_name' => env('SENTRY_SERVER_NAME', gethostname()),

    /*
    |--------------------------------------------------------------------------
    | Context Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration du contexte à capturer avec chaque erreur
    |
    */

    'context' => [
        'user' => true,
        'tags' => true,
        'extra' => true,
        'request' => true,
    ],

    /*
    |--------------------------------------------------------------------------
    | Integrations Configuration
    |--------------------------------------------------------------------------
    |
    | Intégrations Sentry spécifiques
    |
    */

    'integrations' => [
        // Intégration Laravel automatique
        \Sentry\Laravel\Integration::class,
        
        // Intégration base de données (avec sanitisation pour VBG)
        new \Sentry\Integration\RequestIntegration([
            'body_size' => 'medium',
        ]),
    ],

    /*
    |--------------------------------------------------------------------------
    | Before Send Callback
    |--------------------------------------------------------------------------
    |
    | Fonction exécutée avant l'envoi de chaque événement à Sentry
    | CRITIQUE: Doit sanitiser les données sensibles VBG
    |
    */

    'before_send' => function (\Sentry\Event $event, ?\Sentry\EventHint $hint): ?\Sentry\Event {
        // Sanitiser les données sensibles VBG
        if ($event->getRequest()) {
            $request = $event->getRequest();
            
            // Supprimer les données personnelles des victimes
            $sensitiveKeys = [
                'victim_name', 'victim_phone', 'victim_address', 'victim_email',
                'medical_details', 'incident_description', 'personal_details',
                'password', 'password_confirmation', 'token', 'api_key',
                'credit_card', 'ssn', 'national_id'
            ];

            // Nettoyer les données POST/GET
            if (isset($request['data'])) {
                foreach ($sensitiveKeys as $key) {
                    if (is_array($request['data'])) {
                        unset($request['data'][$key]);
                        // Nettoyer également les nested arrays
                        array_walk_recursive($request['data'], function(&$value, $k) use ($sensitiveKeys) {
                            if (in_array(strtolower($k), $sensitiveKeys)) {
                                $value = '[REDACTED-VBG-DATA]';
                            }
                        });
                    }
                }
            }

            // Nettoyer les headers sensibles
            if (isset($request['headers'])) {
                $request['headers'] = array_filter($request['headers'], function($key) {
                    return !in_array(strtolower($key), ['authorization', 'cookie', 'x-api-key']);
                }, ARRAY_FILTER_USE_KEY);
            }
        }

        // Ajouter des tags spécifiques VBG
        $event->setTags(array_merge($event->getTags() ?? [], [
            'project' => 'assistance-msaada',
            'category' => 'vbg-platform',
            'privacy_level' => 'high',
            'data_sensitive' => 'true',
        ]));

        // Ajouter le contexte utilisateur (sans données sensibles)
        if (auth()->check()) {
            $user = auth()->user();
            $event->setUser([
                'id' => $user->id,
                'role' => $user->roles->pluck('name')->first(),
                'organization' => $user->organization->name ?? 'Unknown',
                // PAS d'email ou nom pour la confidentialité
            ]);
        }

        return $event;
    },

    /*
    |--------------------------------------------------------------------------
    | Breadcrumbs Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration des breadcrumbs (trace des actions)
    |
    */

    'breadcrumbs' => [
        'logs' => true,
        'cache' => false, // Désactivé pour éviter les fuites de données
        'livewire' => false,
        'sql_queries' => env('APP_ENV') !== 'production', // Seulement en dev/staging
        'queue_info' => true,
    ],

    /*
    |--------------------------------------------------------------------------
    | Performance Monitoring
    |--------------------------------------------------------------------------
    |
    | Configuration du monitoring de performance
    |
    */

    'traces_sampler' => function (\Sentry\Tracing\SamplingContext $context): float {
        // Échantillonnage adaptatif selon l'endpoint
        $transaction = $context->getTransactionContext();
        $transactionName = $transaction->getName();

        // Endpoints critiques VBG - monitoring plus élevé
        if (strpos($transactionName, '/api/reports') !== false ||
            strpos($transactionName, '/api/victims') !== false ||
            strpos($transactionName, '/api/emergency') !== false) {
            return 0.8; // 80% de tracing pour les endpoints VBG critiques
        }

        // Endpoints d'administration
        if (strpos($transactionName, '/admin') !== false) {
            return 0.3; // 30% de tracing pour l'admin
        }

        // Autres endpoints
        return 0.1; // 10% de tracing standard
    },

    /*
    |--------------------------------------------------------------------------
    | Error Types Configuration
    |--------------------------------------------------------------------------
    |
    | Types d'erreurs à capturer ou ignorer
    |
    */

    'ignore_exceptions' => [
        // Exceptions Laravel communes à ignorer
        \Illuminate\Auth\AuthenticationException::class,
        \Illuminate\Validation\ValidationException::class,
        \Symfony\Component\HttpKernel\Exception\NotFoundHttpException::class,
        \Symfony\Component\HttpKernel\Exception\MethodNotAllowedHttpException::class,
    ],

    /*
    |--------------------------------------------------------------------------
    | Custom Fingerprinting
    |--------------------------------------------------------------------------
    |
    | Groupement intelligent des erreurs similaires
    |
    */

    'before_send_transaction' => function (\Sentry\Event $transaction): ?\Sentry\Event {
        // Ajouter des tags de performance spécifiques
        $transaction->setTags(array_merge($transaction->getTags() ?? [], [
            'performance_category' => 'vbg_platform',
            'monitoring_level' => 'enhanced',
        ]));

        return $transaction;
    },

    /*
    |--------------------------------------------------------------------------
    | VBG Specific Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration spécifique pour la plateforme VBG
    |
    */

    'vbg_config' => [
        // Niveau de logging pour les actions VBG sensibles
        'sensitive_actions_logging' => env('VBG_SENSITIVE_LOGGING', true),
        
        // Anonymisation automatique des données
        'auto_anonymize' => env('VBG_AUTO_ANONYMIZE', true),
        
        // Rétention des données d'erreur (plus courte pour VBG)
        'retention_days' => env('SENTRY_RETENTION_DAYS', 30),
        
        // Notification immédiate pour erreurs critiques VBG
        'immediate_notifications' => [
            'data_breach_attempt',
            'unauthorized_victim_access',
            'report_tampering',
            'security_violation',
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Team & Organization
    |--------------------------------------------------------------------------
    |
    | Configuration pour l'équipe et l'organisation Sentry
    |
    */

    'organization' => env('SENTRY_ORGANIZATION', 'assistance-msaada'),
    'project' => env('SENTRY_PROJECT', 'backend-laravel'),

];