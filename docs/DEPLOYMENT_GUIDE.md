# 📚 GUIDE COMPLET DE DÉPLOIEMENT
## Assistance Msaada 2.0 - De la Configuration aux Secrets

Ce document centralise toutes les étapes nécessaires pour configurer et déployer la plateforme Assistance Msaada 2.0.

---

## 🎯 APERÇU GÉNÉRAL

### Plateforme Assistance Msaada 2.0
- **Objectif** : Plateforme numérique de signalement et gestion des cas de Violence Basée sur le Genre (VBG)
- **Architecture** : Backend Laravel 11, Frontend React 18, Mobile Flutter 3.19
- **Sécurité** : Chiffrement end-to-end, audit complet, authentification multi-facteurs
- **Environnements** : Développement, Staging, Production avec CI/CD automatisé

---

## 🗂️ STRUCTURE DU PROJET

```
assistance-msaada-2.0/
├── 🔧 Configuration & Scripts
│   ├── docker-compose.development.yml
│   ├── docker-compose.staging.yml  
│   ├── docker-compose.production.yml
│   ├── deploy-development.sh
│   ├── .github/workflows/ci-cd.yml
│   └── .github/SECRETS.env.example
├── 🏗️ Backend API (Laravel 11)
│   ├── .env.development
│   ├── .env.staging
│   ├── .env.production
│   └── app/ (Models, Controllers, Services)
├── 🎨 Frontend Web (React 18 + TypeScript)
│   ├── .env.development
│   ├── .env.staging
│   ├── .env.production
│   └── src/ (Components, Services, Store)
├── 📱 Mobile App (Flutter 3.19)
│   └── lib/ (Features, Core, Shared)
└── 📚 Documentation
    ├── GITHUB_SECRETS_SETUP.md
    ├── VALIDATION_SANS_DOCKER.md
    └── DEPLOYMENT_GUIDE.md (ce document)
```

---

## 🚀 PHASE 1: PRÉPARATION INITIALE

### 1.1 Clonage du Repository

```bash
# Cloner le projet
git clone https://github.com/sergenewton/assistance-msaada-2.0.git
cd assistance-msaada-2.0

# Vérifier les branches
git branch -a
git checkout main
```

### 1.2 Vérification des Prérequis

```bash
# Outils nécessaires pour le développement complet :
- Git (gestion de version)
- Docker & Docker Compose (containerisation)
- Node.js 18+ (frontend)
- PHP 8.1+ avec Composer (backend)
- Flutter 3.19+ (mobile)
- OpenSSL (génération des clés)

# Validation rapide :
git --version
docker --version
docker-compose --version
node --version
php --version
composer --version
flutter --version
openssl version
```

---

## 🔐 PHASE 2: CONFIGURATION DES SECRETS

### 2.1 Génération des Clés de Sécurité

Suivre le guide détaillé : `docs/GITHUB_SECRETS_SETUP.md`

**Clés essentielles à générer** :
```bash
# 1. JWT Secrets
STAGING_JWT_SECRET=$(openssl rand -base64 32)
PRODUCTION_JWT_SECRET=$(openssl rand -base64 32)

# 2. Laravel App Keys
STAGING_APP_KEY="base64:$(openssl rand -base64 32)"
PRODUCTION_APP_KEY="base64:$(openssl rand -base64 32)"

# 3. Chiffrement VBG
VBG_ENCRYPTION_KEY_STAGING=$(openssl rand -hex 16)
VBG_ENCRYPTION_KEY_PRODUCTION=$(openssl rand -hex 16)

# 4. Mots de passe bases de données
STAGING_DB_PASSWORD="staging_secure_password_123!"
PRODUCTION_DB_PASSWORD="prod_ultra_secure_pass_456!"

# 5. Clé Health Check
HEALTH_CHECK_SECRET=$(openssl rand -hex 32)
```

### 2.2 Configuration GitHub Actions

1. **Accéder aux paramètres** : Repository → Settings → Secrets and variables → Actions
2. **Ajouter les secrets** : Utiliser la liste complète du guide des secrets
3. **Configurer les environnements** :
   - `staging` : Déploiement automatique
   - `production` : Avec protection et reviewers requis

---

## 🛠️ PHASE 3: DÉVELOPPEMENT LOCAL

### 3.1 Configuration des Environnements

Les fichiers `.env` sont déjà créés pour chaque service :

**Backend** (`backend-api/.env.development`) :
```bash
APP_NAME="Assistance Msaada 2.0"
APP_ENV=development
DB_HOST=db-dev
DB_DATABASE=assistance_msaada_dev
# ... (configuration complète disponible)
```

**Frontend** (`frontend-web/.env.development`) :
```bash
VITE_APP_NAME="Assistance Msaada 2.0"
VITE_API_URL=http://localhost:8000
VITE_FEATURE_REPORTING=true
# ... (configuration complète disponible)
```

### 3.2 Déploiement Local avec Docker

```bash
# Méthode automatisée (recommandée)
./deploy-development.sh

# Ou méthode manuelle
docker-compose -f docker-compose.development.yml up -d

# Vérifier les services
docker-compose -f docker-compose.development.yml ps
```

**URLs d'accès après déploiement** :
- 📱 Frontend: http://localhost:3000
- 🔧 API Backend: http://localhost:8000
- 📊 Health Check: http://localhost:8000/health

### 3.3 Sans Docker (Développement Direct)

Suivre le guide : `docs/VALIDATION_SANS_DOCKER.md`

```bash
# Backend
cd backend-api
composer install
php artisan serve

# Frontend (nouveau terminal)
cd frontend-web
npm install
npm run dev

# Mobile (nouveau terminal)
cd mobile-app
flutter pub get
flutter run
```

---

## 🏗️ PHASE 4: CI/CD ET DÉPLOIEMENTS

### 4.1 Workflow GitHub Actions

Le workflow `.github/workflows/ci-cd.yml` est configuré pour :

**Événements déclencheurs** :
- Push sur `main` → Déploiement staging automatique
- Tag `v*` → Déploiement production (avec approbation)
- Pull Request → Tests de validation

**Étapes automatiques** :
1. 🧪 Tests unitaires et d'intégration
2. 🔨 Build des images Docker
3. 🔍 Scan de sécurité
4. 🚀 Déploiement selon l'environnement
5. ✅ Tests post-déploiement
6. 📊 Notifications (Slack/Email)

### 4.2 Déploiement Staging

```bash
# Déploiement automatique via GitHub Actions
git add .
git commit -m "feat: nouvelle fonctionnalité"
git push origin main

# Le workflow se déclenche automatiquement
# Surveillance : https://github.com/sergenewton/assistance-msaada-2.0/actions
```

### 4.3 Déploiement Production

```bash
# 1. Créer un tag de version
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# 2. Le workflow nécessite une approbation manuelle
# 3. Après approbation → déploiement automatique

# Rollback si nécessaire
git tag -a v1.0.1 -m "Rollback to stable version"
git push origin v1.0.1
```

---

## 🔍 PHASE 5: MONITORING ET MAINTENANCE

### 5.1 Health Checks

**Endpoints de santé configurés** :
```bash
# Backend API
curl http://localhost:8000/health
curl http://localhost:8000/health/database
curl http://localhost:8000/health/redis

# Réponse attendue :
{
  "status": "healthy",
  "timestamp": "2025-10-25T02:30:00Z",
  "services": {
    "database": "ok",
    "redis": "ok",
    "storage": "ok"
  }
}
```

### 5.2 Logs et Debugging

```bash
# Logs Docker Compose
docker-compose -f docker-compose.development.yml logs -f

# Logs spécifiques
docker-compose -f docker-compose.development.yml logs backend-dev
docker-compose -f docker-compose.development.yml logs frontend-dev

# Logs Laravel
tail -f backend-api/storage/logs/laravel.log

# Accès au conteneur pour debug
docker-compose -f docker-compose.development.yml exec backend-dev bash
```

### 5.3 Base de Données

```bash
# Accès MySQL
docker-compose -f docker-compose.development.yml exec db-dev mysql -u assistance_user -p

# Migrations
docker-compose -f docker-compose.development.yml exec backend-dev php artisan migrate

# Seeders
docker-compose -f docker-compose.development.yml exec backend-dev php artisan db:seed
```

---

## 🔒 SÉCURITÉ ET CONFORMITÉ VBG

### 6.1 Mesures de Sécurité Implémentées

**Chiffrement des données** :
- Chiffrement AES-256 pour les données sensibles
- Clés de chiffrement séparées par environnement
- Rotation automatique des clés JWT

**Audit et traçabilité** :
- Logging complet des actions utilisateurs
- Audit trail pour toutes les modifications
- Anonymisation des données de test

**Authentification** :
- JWT avec expiration courte
- Refresh tokens sécurisés
- Authentification multi-facteurs (2FA)

### 6.2 Conformité RGPD/Protection des Données

**Gestion des données personnelles** :
- Chiffrement end-to-end des rapports VBG
- Pseudonymisation des données de victimes
- Droit à l'effacement implémenté

**Contrôles d'accès** :
- Rôles granulaires (Victime, Conseiller, Admin)
- Accès basé sur les zones géographiques
- Logs d'accès aux données sensibles

---

## 🚨 DÉPANNAGE COURANT

### 7.1 Problèmes Docker

```bash
# Docker n'est pas installé
# → Installer Docker Desktop depuis https://docker.com

# Erreur de permissions
sudo chmod +x deploy-development.sh

# Ports déjà utilisés
# → Modifier les ports dans docker-compose.development.yml

# Base de données ne démarre pas
docker-compose -f docker-compose.development.yml logs db-dev
# → Vérifier les mots de passe et la configuration
```

### 7.2 Problèmes de Configuration

```bash
# Secrets manquants dans GitHub
# → Suivre docs/GITHUB_SECRETS_SETUP.md

# Variables d'environnement incorrectes
# → Vérifier les fichiers .env.* de chaque service

# Échec du workflow GitHub Actions
# → Vérifier l'onglet Actions pour les détails d'erreur
```

### 7.3 Problèmes de Développement

```bash
# Dépendances manquantes
cd backend-api && composer install
cd frontend-web && npm install

# Erreurs de migration Laravel
php artisan migrate:fresh --seed

# Cache à nettoyer
php artisan config:clear
php artisan cache:clear
npm run build --prefix frontend-web
```

---

## ✅ CHECKLIST DE DÉPLOIEMENT COMPLET

### Avant le déploiement :
- [ ] Repository Git configuré et synchronisé
- [ ] Tous les secrets GitHub configurés
- [ ] Environnements GitHub (staging/production) créés
- [ ] Docker installé et fonctionnel
- [ ] Fichiers .env générés pour chaque environnement
- [ ] Tests locaux réussis

### Déploiement développement :
- [ ] `./deploy-development.sh` exécuté avec succès
- [ ] Services Docker démarrés (db, redis, backend, frontend)
- [ ] Base de données migrée et seedée
- [ ] Frontend accessible sur http://localhost:3000
- [ ] API accessible sur http://localhost:8000
- [ ] Health checks répondent correctement

### Déploiement staging/production :
- [ ] Push sur `main` déclenche le staging
- [ ] Workflow GitHub Actions réussi
- [ ] Tests automatiques passés
- [ ] Health checks post-déploiement OK
- [ ] Tag de version créé pour la production
- [ ] Approbation manuelle pour la production
- [ ] Monitoring et alertes opérationnels

### Sécurité VBG :
- [ ] Chiffrement des données sensibles activé
- [ ] Audit logging configuré
- [ ] Contrôles d'accès par rôles fonctionnels
- [ ] Anonymisation des données de test
- [ ] Conformité RGPD respectée

---

## 📞 SUPPORT ET RESSOURCES

### Documentation technique :
- 📘 **Guide des secrets** : `docs/GITHUB_SECRETS_SETUP.md`
- 🧪 **Validation sans Docker** : `docs/VALIDATION_SANS_DOCKER.md`
- 🏗️ **Architecture mobile** : `mobile-app/ARCHITECTURE.md`
- 📊 **Base de données** : `database/schema/DATABASE_RELATIONS.md`

### Liens utiles :
- 🔗 **Repository GitHub** : https://github.com/sergenewton/assistance-msaada-2.0
- 🔧 **GitHub Actions** : https://github.com/sergenewton/assistance-msaada-2.0/actions
- ⚙️ **Paramètres Secrets** : https://github.com/sergenewton/assistance-msaada-2.0/settings/secrets/actions

### En cas de problème :
1. **Consulter les logs** : Workflow GitHub Actions ou Docker Compose
2. **Vérifier la configuration** : Secrets et variables d'environnement
3. **Tests locaux** : Utiliser `docs/VALIDATION_SANS_DOCKER.md`
4. **Rollback** : Créer un nouveau tag vers une version stable

---

**Dernière mise à jour** : 25 octobre 2025  
**Version du guide** : 1.0  
**Plateforme** : Assistance Msaada 2.0  
**Environnements supportés** : Development, Staging, Production