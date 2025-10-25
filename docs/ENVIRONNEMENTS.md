# 🌍 CONFIGURATION DES ENVIRONNEMENTS - ASSISTANCE MSAADA 2.0

## Vue d'ensemble

Cette documentation décrit la configuration complète des trois environnements de déploiement pour la plateforme **ASSISTANCE MSAADA** :

- **Development** : Développement local et tests
- **Staging** : Tests d'intégration et validation
- **Production** : Environnement de production en direct

---

## 🏗️ Architecture des Environnements

```
┌─────────────────────────────────────────────────────────────┐
│                     PRODUCTION                              │
│  🌐 assistance-msaada.org                                  │
│  🔒 SSL/TLS + WAF + CDN                                    │
│  🏭 Load Balancer + Auto-scaling                           │
└─────────────────────────────────────────────────────────────┘
                              ↑
┌─────────────────────────────────────────────────────────────┐
│                      STAGING                                │
│  🧪 staging.assistance-msaada.org                         │
│  🔍 Tests d'intégration + Performance                      │
│  📊 Monitoring complet                                      │
└─────────────────────────────────────────────────────────────┘
                              ↑
┌─────────────────────────────────────────────────────────────┐
│                   DEVELOPMENT                               │
│  💻 localhost / Docker local                               │
│  🛠️ Hot reload + Debug tools                              │
│  🎯 Tests unitaires + MailHog                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Structure des Fichiers de Configuration

```
assistance-msaada-2.0/
├── backend-api/
│   ├── .env.development      # Variables dev Laravel
│   ├── .env.staging         # Variables staging Laravel
│   ├── .env.production      # Variables prod Laravel (chiffrées)
│   ├── Dockerfile.dev       # Docker development
│   └── Dockerfile.production # Docker production
│
├── frontend-web/
│   ├── .env.development     # Variables dev React
│   ├── .env.staging        # Variables staging React
│   └── .env.production     # Variables prod React
│
├── docker-compose.development.yml  # Stack complète dev
├── docker-compose.staging.yml      # Stack staging
├── docker-compose.production.yml   # Stack production
│
└── scripts/
    ├── deploy-development.sh    # Script déploiement dev
    ├── deploy-staging.sh       # Script déploiement staging
    └── deploy-production.sh    # Script déploiement production
```

---

## 🛠️ Environnement DEVELOPMENT

### Caractéristiques
- **Purpose** : Développement local et tests rapides
- **Base URL** : `http://localhost`
- **Debug** : Activé avec tous les outils de développement
- **Base de données** : MySQL local avec données de test
- **Storage** : MinIO local (S3 compatible)
- **Email** : MailHog pour les tests d'email

### Services Inclus
```yaml
Services:
  - API Laravel     → localhost:8000
  - Web React       → localhost:5173
  - MySQL           → localhost:3306
  - Redis           → localhost:6379
  - MinIO           → localhost:9000
  - MailHog         → localhost:8025
  - Echo Server     → localhost:6001
```

### Démarrage Rapide
```bash
# Démarrage automatique
./scripts/deploy-development.sh

# Ou manuellement
docker-compose -f docker-compose.development.yml up -d
```

### Variables Clés
```bash
# Backend (.env.development)
APP_ENV=development
APP_DEBUG=true
DB_HOST=127.0.0.1
DB_DATABASE=assistance_msaada_dev

# Frontend (.env.development)
VITE_API_BASE_URL=http://localhost:8000/api/v1
VITE_FEATURE_DEBUG_MODE=true
```

---

## 🧪 Environnement STAGING

### Caractéristiques
- **Purpose** : Tests d'intégration et validation pré-production
- **Base URL** : `https://staging.assistance-msaada.org`
- **Debug** : Limité, logs d'info seulement
- **Base de données** : MySQL avec données de test réalistes
- **Storage** : AWS S3 (bucket staging)
- **SSL** : Certificats valides

### Services Inclus
```yaml
Services:
  - API Laravel     → staging-api.assistance-msaada.org
  - Web React       → staging.assistance-msaada.org
  - MySQL           → Base de données dédiée
  - Redis           → Cache et sessions
  - Queue Workers   → Traitement asynchrone
  - Monitoring      → Prometheus + Grafana
```

### Déploiement
```bash
# Déploiement automatique (CI/CD)
git push origin develop

# Ou manuellement
./scripts/deploy-staging.sh
```

### Variables Clés
```bash
# Backend (.env.staging)
APP_ENV=staging
APP_DEBUG=false
DB_HOST=${DB_HOST}  # Variable d'environnement
MAIL_MAILER=smtp

# Frontend (.env.staging)
VITE_API_BASE_URL=https://staging-api.assistance-msaada.org/api/v1
VITE_SENTRY_ENVIRONMENT=staging
```

---

## 🏭 Environnement PRODUCTION

### Caractéristiques
- **Purpose** : Système en production pour les utilisateurs finaux
- **Base URL** : `https://assistance-msaada.org`
- **Debug** : Désactivé, logs d'erreur seulement
- **Sécurité** : Maximale avec chiffrement E2E
- **Performance** : Optimisé avec cache et CDN
- **Monitoring** : Surveillance 24/7 avec alertes

### Architecture Haute Disponibilité
```yaml
Production Stack:
  - Load Balancer   → Nginx avec SSL
  - API Replicas    → 2+ instances Laravel
  - Web Replicas    → 2+ instances React
  - Database        → MySQL avec réplication
  - Cache           → Redis Cluster
  - Queue           → Workers multiples (critical/default)
  - Storage         → AWS S3 + CloudFront CDN
  - Monitoring      → Full observability stack
```

### Déploiement
```bash
# Déploiement automatique (CI/CD)
git push origin main

# Ou manuellement (avec confirmation)
./scripts/deploy-production.sh
```

### Sécurité Renforcée
```bash
# Chiffrement des secrets
gpg --encrypt --output .env.production.gpg .env.production

# Variables sécurisées
VBG_ENCRYPTION_KEY=${VBG_ENCRYPTION_KEY}  # 32 caractères
JWT_SECRET=${JWT_SECRET}  # Cryptographiquement sécurisé
FORCE_HTTPS=true
SECURE_HEADERS=true
```

---

## 🔄 Workflow de Déploiement CI/CD

### Triggers Automatiques
```yaml
Development:
  - Push vers n'importe quelle branche
  - Tests et linting automatiques

Staging:
  - Push/merge vers 'develop'
  - Déploiement automatique après tests réussis
  - Tests d'intégration post-déploiement

Production:
  - Push/merge vers 'main'
  - Déploiement avec validation manuelle
  - Sauvegarde automatique avant déploiement
  - Rollback automatique en cas d'échec
```

### Pipeline CI/CD
1. **Lint & Tests** → Code quality checks
2. **Build** → Docker images + Security scan
3. **Deploy** → Environment-specific deployment
4. **Verify** → Health checks + Performance tests
5. **Monitor** → Post-deployment monitoring

---

## 📊 Monitoring et Observabilité

### Development
- **Logs** : Console output + Laravel Telescope
- **Debug** : React DevTools + Redux DevTools
- **Email** : MailHog interface
- **Database** : Adminer ou phpMyAdmin

### Staging & Production
- **APM** : Sentry pour error tracking
- **Metrics** : Prometheus + Grafana dashboards
- **Logs** : Centralized logging avec ELK Stack
- **Uptime** : Health checks + Status page
- **Alerts** : Slack + PagerDuty pour production

---

## 🔐 Secrets Management

### Development
- Secrets en clair dans `.env.development`
- Pas de données sensibles

### Staging
- Secrets via variables d'environnement CI/CD
- GitHub Secrets pour les tokens API

### Production
- Secrets chiffrés avec GPG
- Rotation automatique des clés
- Audit trail complet
- Accès restreint par rôle

### Configuration des Secrets GitHub
```bash
# Secrets requis dans GitHub
STAGING_DB_PASSWORD
STAGING_JWT_SECRET
STAGING_PUSHER_APP_KEY
STAGING_PUSHER_APP_SECRET

PRODUCTION_SECRETS_PASSPHRASE
DOCKER_REGISTRY
DOCKER_USERNAME
DOCKER_PASSWORD
SSH_PRIVATE_KEY
SLACK_WEBHOOK_URL
PAGERDUTY_INTEGRATION_KEY
```

---

## 🚨 Procédures d'Urgence

### Rollback Staging
```bash
# Automatique en cas d'échec des tests
# Ou manuel :
./scripts/deploy-staging.sh --rollback
```

### Rollback Production
```bash
# Automatique en cas d'échec critique
# Ou manuel avec confirmation :
./scripts/deploy-production.sh --emergency-rollback
```

### Maintenance Mode
```bash
# Activer le mode maintenance
php artisan down --message="Maintenance en cours" --retry=60

# Désactiver
php artisan up
```

---

## 📝 Checklist de Déploiement

### Avant le Déploiement
- [ ] Tests locaux passent
- [ ] Code review approuvé
- [ ] Variables d'environnement configurées
- [ ] Sauvegarde de la base de données
- [ ] Notification équipe

### Pendant le Déploiement
- [ ] Monitoring des logs en temps réel
- [ ] Vérification des health checks
- [ ] Tests de fumée post-déploiement
- [ ] Vérification des performances

### Après le Déploiement
- [ ] Tests fonctionnels complets
- [ ] Monitoring des métriques
- [ ] Notification de succès
- [ ] Documentation mise à jour

---

## 🆘 Support et Dépannage

### Contacts d'Urgence
- **DevOps Lead** : devops@assistance-msaada.org
- **Tech Lead** : tech@assistance-msaada.org
- **On-call** : +243-XXX-XXX-XXX (24/7 pour production)

### Resources de Dépannage
- **Runbooks** : `/docs/runbooks/`
- **Logs** : Centralized logging dashboard
- **Monitoring** : Grafana dashboards
- **Status Page** : `https://status.assistance-msaada.org`

---

*Documentation mise à jour le 25 octobre 2025*