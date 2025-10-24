# 🚀 ASSISTANCE MSAADA 2.0 - Plateforme de Signalement VBG

## 📋 Vue d'ensemble
Cette plateforme complète de signalement de Violence Basée sur le Genre (VBG) "ASSISTANCE MSAADA" est organisée en **monorepo** avec trois composants interconnectés :

1. **Backend API** - Laravel 11 avec JWT Auth (`backend-api/`)
2. **Frontend Web** - React 18+ avec TypeScript (`frontend-web/`)
3. **Application Mobile** - Flutter 3.19+ avec Clean Architecture (`mobile-app/`)

## 📁 Structure du Monorepo (Recommandée)

```
vbg-platform/
├── apps/
│   ├── api/                    # Backend Laravel API (ex: backend-api/)
│   ├── web/                    # Frontend React Web App (ex: frontend-web/)
│   └── mobile/                 # Application Flutter Mobile (ex: mobile-app/)
├── packages/
│   ├── shared-types/           # Types TypeScript partagés
│   └── shared-config/          # Configurations partagées
├── docs/                       # Documentation
├── scripts/                    # Scripts de build/deploy
├── .github/                    # GitHub Actions & templates
├── docker-compose.yml          # Environnement de développement
├── package.json                # Scripts workspace (optionnel)
└── README.md
```

## Architecture Globale

```
┌─────────────────────────────────────────────────────────┐
│                    VBG Platform                         │
├─────────────────────────────────────────────────────────┤
│  Frontend Web (React/TS)     Mobile App (Flutter)      │
│  Port: 3000                  Android/iOS               │
│         │                           │                  │
│         └─────────────┬─────────────┘                  │
│                       │                                │
│                   Backend API                          │
│                  Laravel (Port: 8000)                  │
│                       │                                │
│                   Database                             │
│                   MySQL/PostgreSQL                     │
└─────────────────────────────────────────────────────────┘
```

## Structure des Projets

```
assistance-msaada-2/
├── backend-api/              # Laravel API Backend
│   ├── app/
│   │   ├── Http/
│   │   │   ├── Controllers/
│   │   │   │   ├── API/V1/
│   │   │   │   └── Auth/
│   │   │   ├── Middleware/
│   │   │   ├── Requests/
│   │   │   └── Resources/
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── Repositories/
│   │   └── [autres dossiers Laravel]
│   ├── database/
│   ├── routes/
│   └── tests/
│
├── frontend-web/             # React TypeScript Frontend
│   ├── src/
│   │   ├── components/
│   │   │   ├── UI/
│   │   │   ├── Layout/
│   │   │   ├── Forms/
│   │   │   └── Reports/
│   │   ├── pages/
│   │   │   ├── Auth/
│   │   │   ├── Dashboard/
│   │   │   └── Reports/
│   │   ├── services/
│   │   ├── hooks/
│   │   ├── store/
│   │   └── utils/
│   └── public/
│
└── mobile-app/               # Flutter Mobile App
    ├── lib/
    │   ├── core/
    │   ├── features/
    │   │   ├── auth/
    │   │   │   ├── data/
    │   │   │   ├── domain/
    │   │   │   └── presentation/
    │   │   └── reports/
    │   │       ├── data/
    │   │       ├── domain/
    │   │       └── presentation/
    │   └── shared/
    ├── assets/
    └── test/
```

## Technologies Utilisées

### Backend (Laravel)
- **Framework** : Laravel 10+
- **Authentification** : JWT (tymon/jwt-auth)
- **API** : RESTful avec versioning
- **Base de données** : MySQL/PostgreSQL
- **Storage** : Local/S3 pour fichiers
- **Tests** : PHPUnit

### Frontend (React)
- **Framework** : React 18+
- **Langage** : TypeScript
- **Bundler** : Vite
- **State Management** : Redux Toolkit
- **Routing** : React Router v6
- **HTTP Client** : Axios
- **UI Library** : Tailwind CSS + HeadlessUI
- **Forms** : React Hook Form + Zod
- **Tests** : Vitest + Testing Library

### Mobile (Flutter)
- **Framework** : Flutter 3.13+
- **Langage** : Dart
- **Architecture** : Clean Architecture
- **State Management** : BLoC Pattern
- **Navigation** : GoRouter
- **HTTP Client** : Dio
- **Local Storage** : Hive
- **Tests** : Flutter Test + Mocktail

## Démarrage Rapide

### 1. Backend Laravel
```bash
cd backend-api
composer install
cp .env.example .env
php artisan key:generate
php artisan jwt:secret
php artisan migrate --seed
php artisan serve --port=8000
```

### 2. Frontend React
```bash
cd frontend-web
npm install
npm run dev
```

### 3. Mobile Flutter
```bash
cd mobile-app
flutter pub get
flutter pub run build_runner build
flutter run
```

## Fonctionnalités Principales

### Gestion des Utilisateurs
- Inscription/Connexion sécurisée
- Profils utilisateurs (victimes, conseillers, administrateurs)
- Gestion des permissions et rôles

### Signalement VBG
- Formulaires de signalement sécurisés
- Upload de documents/preuves
- Géolocalisation des incidents
- Statuts de traitement

### Suivi et Support
- Tableau de bord pour le suivi
- Notifications push/email
- Chat sécurisé avec conseillers
- Ressources d'aide et d'information

### Administration
- Dashboard administrateur
- Statistiques et rapports
- Gestion des utilisateurs
- Modération du contenu

## Sécurité et Confidentialité

- **Chiffrement** : Données sensibles chiffrées
- **Authentification** : JWT avec refresh tokens
- **Anonymisation** : Option de signalement anonyme
- **HTTPS** : Communication sécurisée
- **Validation** : Validation stricte des données
- **Logs** : Journalisation sécurisée

## Déploiement

### Backend
- Docker + Docker Compose
- Serveur web (Nginx/Apache)
- Base de données (MySQL/PostgreSQL)
- Queue Worker (Redis)

### Frontend
- Build statique (Vite)
- CDN (Cloudflare/AWS CloudFront)
- Hébergement (Vercel/Netlify)

### Mobile
- Google Play Store (Android)
- Apple App Store (iOS)
- APK direct pour tests

## Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push sur la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## Licence

Ce projet est sous licence MIT. Voir `LICENSE` pour plus de détails.

## Support

Pour le support technique, contactez : support@vbgplatform.com