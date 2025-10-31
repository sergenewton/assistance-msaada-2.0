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

## Développement local (serveur mock)

Le script `quick-start-local.sh` démarre un serveur PHP intégré sur le port 8000 en utilisant un routeur léger `public/api-test.php`. Ce routeur mock propose des endpoints compatibles pour l'auth et les signalements sans passer par le Kernel Laravel, pratique pour les itérations rapides front-end.

Endpoints mock importants:
- `GET /api/health`
- `POST /api/v1/auth/login`
- `GET /api/v1/auth/me`
- `POST /api/v1/reports` (soumission publique)
- `GET /api/v1/reports/{tracking}` (consultation publique)
- `GET /api/v1/reports/unprocessed` (opérateur – non traités)
- `GET /api/v1/reports/unprocessed-urgent` (opérateur – non traités urgents)

Remarques:
- Ces endpoints mock lisent/écrivent dans un petit stockage fichier, avec support MySQL optionnel si la base est démarrée.
- En mode local via ce routeur, les routes Laravel ajoutées dans `routes/api.php` ne sont pas utilisées. Pour tester les vraies routes Laravel, lancez l'API avec `php artisan serve` (ou via le conteneur) et utilisez `public/index.php` comme point d'entrée.