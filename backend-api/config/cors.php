<?php

return [
    // Paths that should be processed by CORS
    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    // Allowed HTTP methods
    'allowed_methods' => ['*'],

    // Explicitly allow local dev frontends
    'allowed_origins' => [
        'http://127.0.0.1:3000',
        'http://localhost:3000',
    ],

    // You can also use patterns, e.g., for ports
    'allowed_origins_patterns' => [],

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
