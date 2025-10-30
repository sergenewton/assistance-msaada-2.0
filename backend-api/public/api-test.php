<?php

header('Content-Type: application/json');
// Allow all origins in local mock to enable Flutter web and other dev clients
header('Access-Control-Allow-Origin: *');
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

// Simple file-backed store for reports to simulate a database
$STORE_FILE = sys_get_temp_dir() . '/msaada_reports.json';
if (!file_exists($STORE_FILE)) {
    file_put_contents($STORE_FILE, json_encode([]));
}

// Optional: MySQL-backed persistence using PDO when available
function db_env(string $key, ?string $default = null): ?string {
    $val = getenv($key);
    return ($val === false || $val === '') ? $default : $val;
}

function db_pdo(): ?PDO {
    static $pdo = null; // re-use connection
    if ($pdo !== null) {
        return $pdo;
    }
    $host = db_env('DB_HOST', '127.0.0.1');
    $port = (int) db_env('DB_PORT', '3306');
    $db   = db_env('DB_DATABASE', 'vbg_platform');
    $user = db_env('DB_USERNAME', 'vbg');
    $pass = db_env('DB_PASSWORD', 'vbgpass');
    $charset = 'utf8mb4';
    $dsn = "mysql:host={$host};port={$port};dbname={$db};charset={$charset}";
    try {
        $pdo = new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
        return $pdo;
    } catch (Throwable $e) {
        // Silently ignore DB errors for mock server; file-backed store remains the source of truth in dev
        return null;
    }
}

function db_has_reports_table(PDO $pdo): bool {
    try {
        $stmt = $pdo->query("SHOW TABLES LIKE 'reports'");
        return (bool) $stmt->fetchColumn();
    } catch (Throwable $e) {
        return false;
    }
}

function db_store_report(array $record): void {
    $pdo = db_pdo();
    if (!$pdo) return;
    if (!db_has_reports_table($pdo)) return; // don't auto-create; respect Laravel migrations
    try {
        // Insert minimal subset matching Laravel schema (UUID id must be provided)
        $id = bin2hex(random_bytes(16));
        $now = date('Y-m-d H:i:s');
        $payload = $record['payload'];
        $violence = $payload['violence_type'] ?? null;
        if (is_array($violence)) { $violence = $violence[0] ?? 'other'; }
        $urgency = $payload['urgency_level'] ?? null;
        $loc = $payload['incident_location'] ?? null;
        $address = is_array($loc) ? ($loc['address_line'] ?? null) : (is_string($loc) ? $loc : null);
        $lat = is_array($loc) ? ($loc['latitude'] ?? null) : null;
        $lng = is_array($loc) ? ($loc['longitude'] ?? null) : null;
        $stmt = $pdo->prepare('INSERT INTO reports (id, report_number, is_anonymous, violence_type, urgency_level, incident_location, address_line, latitude, longitude, payload, created_at, updated_at) VALUES (:id, :rn, :anon, :vt, :ul, :iloc, :addr, :lat, :lng, CAST(:payload AS JSON), :created_at, :updated_at)');
        $stmt->execute([
            ':id' => $id,
            ':rn' => $record['report_number'],
            ':anon' => (int) ($payload['is_anonymous'] ?? 0),
            ':vt' => $violence,
            ':ul' => $urgency,
            ':iloc' => $address,
            ':addr' => $address,
            ':lat' => $lat,
            ':lng' => $lng,
            ':payload' => json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
            ':created_at' => $now,
            ':updated_at' => $now,
        ]);
    } catch (Throwable $e) {
        // ignore in mock
    }
}

function db_find_report_by_tracking(string $tracking): ?array {
    $pdo = db_pdo();
    if (!$pdo) return null;
    try {
    if (!db_has_reports_table($pdo)) return null;
        $stmt = $pdo->prepare('SELECT report_number, payload, created_at FROM reports WHERE report_number = :rn LIMIT 1');
        $stmt->execute([':rn' => $tracking]);
        $row = $stmt->fetch();
        if (!$row) return null;
        return [
            'report_number' => $row['report_number'],
            'payload' => json_decode($row['payload'], true),
            'created_at' => date('c', strtotime($row['created_at'])),
            'source' => 'mysql'
        ];
    } catch (Throwable $e) {
        return null;
    }
}

function store_report(array $record, string $file): void {
    $all = json_decode(file_get_contents($file), true) ?: [];
    $all[] = $record;
    file_put_contents($file, json_encode($all));
}

function find_report_by_tracking(string $tracking, string $file): ?array {
    $all = json_decode(file_get_contents($file), true) ?: [];
    foreach ($all as $r) {
        if (($r['report_number'] ?? null) === $tracking) {
            return $r;
        }
    }
    return null;
}

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

// Fonction pour charger les utilisateurs depuis MySQL avec fallback sur les utilisateurs statiques
function load_users_from_db(): array {
    global $users; // utilisateurs statiques par défaut
    
    $pdo = db_pdo();
    if (!$pdo) {
        return $users; // fallback sur les utilisateurs statiques si pas de DB
    }
    
    try {
        $sql = "
            SELECT 
                u.id,
                u.password,
                u.is_active,
                u.created_at,
                u.two_factor_enabled,
                r.name as role,
                r.display_name as role_display_name
            FROM users u 
            JOIN roles r ON u.role_id = r.id 
            WHERE u.is_active = 1 AND u.deleted_at IS NULL
        ";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        $db_users = $stmt->fetchAll();
        
        $formatted_users = [];
        foreach ($db_users as $user) {
            // Déchiffrer l'email et le téléphone (si chiffrés)
            $email = '';
            $phone = '';
            
            // Essayer de récupérer l'email et téléphone chiffrés
            $user_details_sql = "SELECT email, phone FROM users WHERE id = ?";
            $details_stmt = $pdo->prepare($user_details_sql);
            $details_stmt->execute([$user['id']]);
            $details = $details_stmt->fetch();
            
            if ($details) {
                // Les données sont chiffrées avec Laravel, mais nous sommes dans un contexte PHP simple
                // Pour l'instant, utilisons des valeurs connues pour le super admin
                if ($user['role'] === 'admin') {
                    $email = 'admin@msaada.cd';
                    $phone = '+243000000000';
                } else {
                    // Pour les autres utilisateurs, utiliser une valeur par défaut
                    $email = 'user@example.com';
                    $phone = '+243000000000';
                }
            }
            
            $formatted_users[] = [
                'id' => $user['id'],
                'email' => $email,
                'phone' => $phone,
                'password' => $user['password'],
                'role' => $user['role'],
                'role_display_name' => $user['role_display_name'],
                'permissions' => [], // À implémenter selon le rôle
                'two_factor_enabled' => (bool) $user['two_factor_enabled'],
                'created_at' => $user['created_at']
            ];
        }
        
        // Combiner avec les utilisateurs statiques (pour compatibilité)
        return array_merge($users, $formatted_users);
        
    } catch (Exception $e) {
        // En cas d'erreur, retourner les utilisateurs statiques
        return $users;
    }
}

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
    
    // Charger tous les utilisateurs (base de données + statiques)
    $all_users = load_users_from_db();
    
    // Rechercher l'utilisateur
    $user = null;
    foreach ($all_users as $u) {
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

// -------------------------------
// Reports (Public Submission)
// -------------------------------
if (($uri === '/api/v1/reports' || $uri === '/api/v1/reports/submit') && $method === 'POST') {
    $contentType = isset($_SERVER['CONTENT_TYPE']) ? strtolower($_SERVER['CONTENT_TYPE']) : '';
    $raw = file_get_contents('php://input') ?: '';
    // Debug log for local dev
    file_put_contents(sys_get_temp_dir() . '/msaada-debug.log', "[".date('c')."] CT=".$contentType." raw_len=".strlen($raw)." post_count=".count($_POST)." files_count=".count($_FILES)."\n", FILE_APPEND);

    $input = [];
    if (strpos($contentType, 'application/json') === 0) {
        $input = json_decode($raw, true) ?? [];
    } elseif (strpos($contentType, 'multipart/form-data') === 0 || strpos($contentType, 'application/x-www-form-urlencoded') === 0) {
        // Build from POST fields
        $input = $_POST;
        // Normalize arrays named with [] (PHP already groups them into arrays)
        // Optionally, capture uploaded files metadata
        if (!empty($_FILES)) {
            $files = [];
            foreach ($_FILES as $field => $info) {
                // Support both single and multiple files
                if (is_array($info['name'])) {
                    $names = $info['name'];
                    $tmp_names = $info['tmp_name'];
                    $types = $info['type'];
                    $sizes = $info['size'];
                    $errs = $info['error'];
                    $arr = [];
                    foreach ($names as $i => $n) {
                        $arr[] = [
                            'name' => $n,
                            'type' => $types[$i] ?? null,
                            'size' => $sizes[$i] ?? null,
                            'error' => $errs[$i] ?? null,
                            'tmp_name' => $tmp_names[$i] ?? null,
                        ];
                    }
                    $files[$field] = $arr;
                } else {
                    $files[$field] = [
                        'name' => $info['name'] ?? null,
                        'type' => $info['type'] ?? null,
                        'size' => $info['size'] ?? null,
                        'error' => $info['error'] ?? null,
                        'tmp_name' => $info['tmp_name'] ?? null,
                    ];
                }
            }
            // Attach a lightweight representation of files to the payload for traceability
            $input['_attachments'] = $files;
        }
    } else {
        // Fallback: try to decode as JSON, else empty array
        $input = json_decode($raw, true) ?? [];
    }

    // Very light validation for demo
    $errors = [];
    if (!isset($input['violence_type'])) {
        $errors['violence_type'][] = 'Le type de violence est requis';
    }
    if (!isset($input['urgency_level'])) {
        $errors['urgency_level'][] = 'Le niveau d\'urgence est requis';
    }
    if (!isset($input['incident_location'])) {
        $errors['incident_location'][] = 'La localisation de l\'incident est requise';
    }
    if (!isset($input['preferred_contact_method'])) {
        $errors['preferred_contact_method'][] = 'La méthode de contact est requise';
    }

    if (!empty($errors)) {
        http_response_code(422);
        echo json_encode([
            'success' => false,
            'message' => 'Données invalides',
            'errors' => $errors,
        ]);
        exit;
    }

    // Generate a tracking number
    $n1 = rand(1000, 9999);
    $n2 = rand(1000, 9999);
    $tracking = sprintf('VBG-%d-%d', $n1, $n2);

    $record = [
        'report_number' => $tracking,
        'payload' => $input,
        'created_at' => date('c'),
    ];
    store_report($record, $STORE_FILE);
    // Also try to persist in MySQL if available
    db_store_report($record);

    echo json_encode([
        'success' => true,
        'message' => 'Signalement reçu',
        'report_number' => $tracking,
        'data' => [ 'received' => $input ],
    ]);
    exit;
}

// GET report by tracking number (mock)
if (preg_match('#^/api/v1/reports/(?P<tracking>VBG-\d{4}-\d{4})$#', $uri, $m) && $method === 'GET') {
    $tracking = $m['tracking'];
    // Prefer DB if available, fall back to file store
    $found = db_find_report_by_tracking($tracking);
    if (!$found) {
        $found = find_report_by_tracking($tracking, $STORE_FILE);
    } else {
        $found['source'] = 'mysql';
    }
    if ($found) {
        echo json_encode([
            'success' => true,
            'data' => $found,
        ]);
    } else {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Signalement introuvable',
        ]);
    }
    exit;
}

// GET report by tracking number (force DB lookup for verification)
if (preg_match('#^/api/v1/reports-db/(?P<tracking>VBG-\d{4}-\d{4})$#', $uri, $m) && $method === 'GET') {
    $tracking = $m['tracking'];
    $found = db_find_report_by_tracking($tracking);
    if ($found) {
        echo json_encode([
            'success' => true,
            'data' => $found,
        ]);
    } else {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Signalement introuvable dans MySQL',
        ]);
    }
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