<?php

return [
    // Paths that should be processed by CORS
    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    // Allowed HTTP methods
    'allowed_methods' => ['*'],

    // Explicitly allow local dev frontends
    // For Flutter Web dev server the port is dynamic, so prefer origin patterns below
    'allowed_origins' => [
        // Keep common fixed ports if used by other frontends
        'http://127.0.0.1:3000',
        'http://localhost:3000',
    ],

    // Allow any localhost/127.0.0.1 with any port (useful for Flutter/Vite dev servers)
    'allowed_origins_patterns' => [
        // HTTP dev origins
        '#^http://localhost(?::\\d+)?$#',
        '#^http://127\\.0\\.0\\.1(?::\\d+)?$#',
        // HTTPS dev origins (in case Chrome serves over https locally)
        '#^https://localhost(?::\\d+)?$#',
        '#^https://127\\.0\\.0\\.1(?::\\d+)?$#',
    ],

    // Allowed headers
    'allowed_headers' => ['*'],

    // Headers exposed to the browser
    'exposed_headers' => [],

    // Caching time for preflight (in seconds)
    'max_age' => 0,

    // If you need cookies/authorization with cross-site requests set to true.
    // We use Authorization: Bearer tokens, so leave it false.
    'supports_credentials' => false,
];
