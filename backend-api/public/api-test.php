<?php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: http://localhost:3000');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Allow-Credentials: true');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];

// Simulation de base de données
// Données des 6 profils utilisateurs
$roles = [
    ['name' => 'survivante', 'display_name' => 'Survivante / Témoin', 'access' => 'mobile'],
    ['name' => 'aps', 'display_name' => 'Agent Psychosocial (APS)', 'access' => 'web + mobile'],
    ['name' => 'operateur', 'display_name' => 'Opérateur Centre d\'Écoute', 'access' => 'web'],
    ['name' => 'organisation', 'display_name' => 'Organisation Partenaire', 'access' => 'web (portail)'],
    ['name' => 'admin', 'display_name' => 'Administrateur Système', 'access' => 'web (admin)'],
    ['name' => 'superviseur', 'display_name' => 'Superviseur / Coordinateur', 'access' => 'web (vue globale)']
];

$users = [
    [
        'id' => 1,
        'email' => 'survivor@example.com',
        'phone' => '+243901234567',
        'password' => password_hash('SecurePass123!', PASSWORD_DEFAULT),
        'role' => 'survivante',
        'role_display_name' => 'Survivante',
        'permissions' => ['reports.create', 'reports.view_own_status', 'messages.send_to_aps'],
        'two_factor_enabled' => false,
        'created_at' => '2025-01-01T00:00:00Z'
    ],
    [
        'id' => 2,
        'email' => 'aps@msaada.org',
        'phone' => '+243901234568',
        'password' => password_hash('APSSecure123!', PASSWORD_DEFAULT),
        'role' => 'aps',
        'role_display_name' => 'Agent Psychosocial (APS)',
        'permissions' => ['cases.view_assigned', 'messages.secure_chat', 'cases.update_status', 'sessions.document'],
        'two_factor_enabled' => false,
        'created_at' => '2025-01-01T00:00:00Z'
    ],
    [
        'id' => 3,
        'email' => 'operateur@msaada.org',
        'phone' => '+243901234569',
        'password' => password_hash('OperatorSecure123!', PASSWORD_DEFAULT),
        'role' => 'operateur',
        'role_display_name' => 'Opérateur Centre d\'Écoute',
        'permissions' => ['reports.receive_all', 'cases.evaluate_urgency', 'referrals.create', 'cases.assign_aps'],
        'two_factor_enabled' => false,
        'created_at' => '2025-01-01T00:00:00Z'
    ],
    [
        'id' => 4,
        'email' => 'admin@msaada.org',
        'phone' => '+243901234573',
        'password' => password_hash('AdminSecure123!', PASSWORD_DEFAULT),
        'role' => 'admin',
        'role_display_name' => 'Administrateur Système',
        'permissions' => ['users.manage_all', 'system.configure', 'organizations.manage', 'audit.view_logs'],
        'two_factor_enabled' => false,
        'created_at' => '2025-01-01T00:00:00Z'
    ]
];

// Route: Health Check
if ($uri === '/api/health' && $method === 'GET') {
    echo json_encode([
        'status' => 'ok',
        'timestamp' => date('c'),
        'service' => 'Assistance Msaada API',
        'version' => '2.0.0'
    ]);
    exit;
}

// Route: Login
if ($uri === '/api/v1/auth/login' && $method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input || !isset($input['identifier']) || !isset($input['password'])) {
        http_response_code(422);
        echo json_encode([
            'success' => false,
            'message' => 'Données manquantes',
            'errors' => [
                'identifier' => ['L\'identifiant est requis'],
                'password' => ['Le mot de passe est requis']
            ]
        ]);
        exit;
    }
    
    // Rechercher l'utilisateur
    $user = null;
    foreach ($users as $u) {
        if ($u['email'] === $input['identifier'] || $u['phone'] === $input['identifier']) {
            if (password_verify($input['password'], $u['password'])) {
                $user = $u;
                break;
            }
        }
    }
    
    if (!$user) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Identifiants invalides'
        ]);
        exit;
    }
    
    // Générer un token JWT simulé
    $token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJhc3Npc3RhbmNlLW1zYWFkYSIsImlhdCI6' . time() . ',"exp":' . (time() + 3600) . ',"user_id":' . $user['id'] . '}';
    
    unset($user['password']);
    
    echo json_encode([
        'success' => true,
        'message' => 'Connexion réussie',
        'data' => [
            'user' => $user,
            'token' => [
                'access_token' => $token,
                'token_type' => 'Bearer',
                'expires_at' => date('c', time() + 3600)
            ]
        ]
    ]);
    exit;
}

// Route: Register
if ($uri === '/api/v1/auth/register' && $method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input || 
        (!isset($input['email']) && !isset($input['phone'])) ||
        !isset($input['password']) ||
        !isset($input['terms_accepted']) ||
        !$input['terms_accepted']) {
        
        http_response_code(422);
        echo json_encode([
            'success' => false,
            'message' => 'Données invalides',
            'errors' => [
                'email' => isset($input['email']) ? [] : ['L\'email ou le téléphone est requis'],
                'password' => isset($input['password']) ? [] : ['Le mot de passe est requis'],
                'terms_accepted' => (isset($input['terms_accepted']) && $input['terms_accepted']) ? [] : ['Vous devez accepter les conditions']
            ]
        ]);
        exit;
    }
    
    // Créer un nouvel utilisateur
    $newUser = [
        'id' => count($users) + 1,
        'email' => $input['email'] ?? null,
        'phone' => $input['phone'] ?? null,
        'role' => $input['role'] ?? 'survivante',
        'role_display_name' => ucfirst($input['role'] ?? 'survivante'),
        'permissions' => ['reports.view', 'reports.create'],
        'two_factor_enabled' => false,
        'created_at' => date('c')
    ];
    
    // Générer token
    $token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJhc3Npc3RhbmNlLW1zYWFkYSIsImlhdCI6' . time() . ',"exp":' . (time() + 3600) . ',"user_id":' . $newUser['id'] . '}';
    
    echo json_encode([
        'success' => true,
        'message' => 'Inscription réussie',
        'data' => [
            'user' => $newUser,
            'token' => [
                'access_token' => $token,
                'token_type' => 'Bearer',
                'expires_at' => date('c', time() + 3600)
            ]
        ]
    ]);
    exit;
}

// Route: Me (utilisateur connecté)
if ($uri === '/api/v1/auth/me' && $method === 'GET') {
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    
    if (!str_starts_with($authHeader, 'Bearer ')) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Token requis'
        ]);
        exit;
    }
    
    // Simuler utilisateur à partir du token (normalement on décode le JWT)
    $user = $users[0];
    unset($user['password']);
    
    echo json_encode([
        'success' => true,
        'data' => [
            'user' => $user
        ]
    ]);
    exit;
}

// Route: Verify Token
if ($uri === '/api/v1/auth/verify' && $method === 'GET') {
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    
    if (!str_starts_with($authHeader, 'Bearer ')) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Token requis'
        ]);
        exit;
    }
    
    echo json_encode([
        'success' => true,
        'data' => [
            'valid' => true,
            'expires_at' => date('c', time() + 3600)
        ]
    ]);
    exit;
}

// Route: Logout
if ($uri === '/api/v1/auth/logout' && $method === 'POST') {
    echo json_encode([
        'success' => true,
        'message' => 'Déconnexion réussie'
    ]);
    exit;
}

// Route: Get Roles
if ($uri === '/api/v1/auth/roles' && $method === 'GET') {
    echo json_encode([
        'success' => true,
        'message' => 'Rôles récupérés avec succès',
        'data' => [
            'roles' => $roles,
            'total_roles' => count($roles)
        ]
    ]);
    exit;
}

// Route: Get Users by Role
if ($uri === '/api/v1/auth/users' && $method === 'GET') {
    $role_filter = $_GET['role'] ?? null;
    $filtered_users = $role_filter 
        ? array_filter($users, fn($u) => $u['role'] === $role_filter)
        : $users;
    
    // Remove passwords from response
    $safe_users = array_map(function($user) {
        unset($user['password']);
        return $user;
    }, $filtered_users);
    
    echo json_encode([
        'success' => true,
        'message' => 'Utilisateurs récupérés avec succès',
        'data' => [
            'users' => array_values($safe_users),
            'total_users' => count($safe_users),
            'filter_applied' => $role_filter
        ]
    ]);
    exit;
}

// Route par défaut
http_response_code(404);
echo json_encode([
    'success' => false,
    'message' => 'Route non trouvée',
    'available_routes' => [
        'GET /api/health',
        'POST /api/v1/auth/login',
        'POST /api/v1/auth/register',
        'GET /api/v1/auth/me',
        'GET /api/v1/auth/verify',
        'POST /api/v1/auth/logout',
        'GET /api/v1/auth/roles',
        'GET /api/v1/auth/users'
    ]
]);