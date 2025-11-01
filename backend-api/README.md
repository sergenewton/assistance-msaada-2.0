# VBG Platform Backend API

## Description
API backend pour la plateforme de signalement VBG (Violence Basée sur le Genre)

## Structure des Dossiers

```
backend-api/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── API/V1/          # Contrôleurs API versionnés
│   │   │   └── Auth/            # Contrôleurs d'authentification
│   │   ├── Middleware/          # Middleware personnalisé
│   │   ├── Requests/           # Validation des requêtes
│   │   └── Resources/          # Resources API (transformations JSON)
│   ├── Models/                 # Modèles Eloquent
│   ├── Services/              # Services métier
│   ├── Repositories/          # Pattern Repository
│   ├── Notifications/         # Notifications
│   ├── Jobs/                  # Jobs en arrière-plan
│   ├── Events/                # Événements
│   └── Listeners/             # Écouteurs d'événements
├── database/
│   ├── migrations/            # Migrations de base de données
│   ├── seeders/              # Seeders
│   └── factories/            # Factories pour les tests
├── routes/                   # Routes API et web
├── config/                   # Configuration
├── storage/
│   └── app/
│       └── public/
│           ├── reports/       # Fichiers des signalements
│           └── documents/     # Documents uploadés
└── tests/
    ├── Feature/              # Tests d'intégration
    └── Unit/                 # Tests unitaires
```

## Conventions de Nommage

### Modèles
- PascalCase : `Report`, `User`, `VbgCase`
- Singulier : `Report` (pas `Reports`)

### Contrôleurs
- PascalCase + "Controller" : `ReportController`, `AuthController`
- Versioning API : `API/V1/ReportController`

### Services
- PascalCase + "Service" : `ReportService`, `NotificationService`

### Repositories
- PascalCase + "Repository" : `ReportRepository`, `UserRepository`

### Requests
- PascalCase + "Request" : `CreateReportRequest`, `UpdateUserRequest`

### Resources
- PascalCase + "Resource" : `ReportResource`, `UserResource`

### Migrations
- snake_case avec timestamp : `2024_01_01_000000_create_reports_table`

### Routes API
- Kebab-case : `/api/v1/vbg-reports`, `/api/v1/user-profile`

## Installation

```bash
composer install
cp .env.example .env
php artisan key:generate
php artisan jwt:secret
php artisan migrate
php artisan db:seed
php artisan storage:link
php artisan serve
```

## Tests

```bash
php artisan test
```

## Développement local (Laravel)

Recommandé: utilisez le lanceur unifié à la racine du dépôt pour installer et démarrer la stack (API + Front + DB) en un seul geste.

Dockerisé SEULEMENT (échoue si Docker indisponible)
```bash
./scripts/install-and-run.sh --db-docker
```

Local SEULEMENT (échoue si MySQL local indisponible)
```bash
./scripts/install-and-run.sh --db-local
```

Variantes utiles
```bash
./scripts/install-and-run.sh --db-docker --status
./scripts/install-and-run.sh --db-local --backend-only
./scripts/install-and-run.sh --db-local --frontend-only
./scripts/install-and-run.sh --db-docker --db-only
./scripts/install-and-run.sh --stop
```

Endpoints utiles:
- `GET /api/health`
- `POST /api/v1/auth/login`
- `POST /api/v1/reports/submit` (soumission publique)
- `GET /api/v1/reports/{tracking}` (consultation publique)

Notes:
- Le script de test `public/api-test.php` a été supprimé et ne doit plus être utilisé. Toutes les requêtes passent par Laravel et persistent en base MySQL (plus aucun stockage JSON).
- `quick-start-local.sh` est déprécié et redirige vers `scripts/install-and-run.sh`.
- Assurez-vous que MySQL est démarré (le script peut le lancer via Docker) avant d'exécuter les migrations.