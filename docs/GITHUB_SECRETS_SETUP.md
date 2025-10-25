# 🔐 GUIDE CONFIGURATION SECRETS GITHUB ACTIONS
## Assistance Msaada 2.0

Ce guide vous accompagne dans la configuration complète des secrets et variables nécessaires pour le pipeline CI/CD.

---

## 📋 PRÉREQUIS

- Accès administrateur au repository GitHub `sergenewton/assistance-msaada-2.0`
- Terminal avec OpenSSL installé
- PHP installé (pour Laravel)
- Git configuré

---

## 🔑 GÉNÉRATION DES CLÉS DE SÉCURITÉ

### 1. Clés JWT (Laravel)

```bash
# JWT Secret pour staging
STAGING_JWT_SECRET=$(openssl rand -base64 32)
echo "STAGING_JWT_SECRET: $STAGING_JWT_SECRET"

# JWT Secret pour production
PRODUCTION_JWT_SECRET=$(openssl rand -base64 32)
echo "PRODUCTION_JWT_SECRET: $PRODUCTION_JWT_SECRET"
```

### 2. Clés d'application Laravel

```bash
# App Key pour staging
cd backend-api
php artisan key:generate --show
# Copier le résultat (format: base64:xxxxx)

# Ou générer manuellement
STAGING_APP_KEY="base64:$(openssl rand -base64 32)"
PRODUCTION_APP_KEY="base64:$(openssl rand -base64 32)"

echo "STAGING_APP_KEY: $STAGING_APP_KEY"
echo "PRODUCTION_APP_KEY: $PRODUCTION_APP_KEY"
```

### 3. Clés de chiffrement VBG

```bash
# Clés de chiffrement pour les données sensibles (32 caractères)
VBG_ENCRYPTION_KEY_STAGING=$(openssl rand -hex 16)
VBG_ENCRYPTION_KEY_PRODUCTION=$(openssl rand -hex 16)

echo "VBG_ENCRYPTION_KEY_STAGING: $VBG_ENCRYPTION_KEY_STAGING"
echo "VBG_ENCRYPTION_KEY_PRODUCTION: $VBG_ENCRYPTION_KEY_PRODUCTION"
```

### 4. Clés SSH pour déploiement

```bash
# Générer une paire de clés SSH
ssh-keygen -t rsa -b 4096 -C "github-actions@assistance-msaada.org" -f ~/.ssh/assistance_msaada_deploy

# Encoder la clé privée en base64 (pour GitHub Secret)
cat ~/.ssh/assistance_msaada_deploy | base64 -w 0
# Copier ce résultat pour SSH_PRIVATE_KEY

# Afficher la clé publique (à ajouter sur les serveurs)
cat ~/.ssh/assistance_msaada_deploy.pub
```

### 5. Clé de santé (Health Check)

```bash
HEALTH_CHECK_SECRET=$(openssl rand -hex 32)
echo "HEALTH_CHECK_SECRET: $HEALTH_CHECK_SECRET"
```

---

## ⚙️ CONFIGURATION GITHUB ACTIONS

### Étape 1: Accéder aux paramètres

1. Aller sur https://github.com/sergenewton/assistance-msaada-2.0
2. Cliquer sur **Settings** (onglet du repository)
3. Dans le menu de gauche, cliquer sur **Secrets and variables** → **Actions**

### Étape 2: Configurer les Secrets Repository

Cliquer sur **New repository secret** et ajouter chacun des secrets suivants :

#### 🔐 SECRETS ESSENTIELS (minimum requis)

| Nom du Secret | Valeur | Description |
|---------------|--------|-------------|
| `STAGING_DB_PASSWORD` | `staging_secure_password_123!` | Mot de passe base de données staging |
| `PRODUCTION_DB_PASSWORD` | `prod_ultra_secure_pass_456!` | Mot de passe base de données production |
| `STAGING_JWT_SECRET` | `[généré précédemment]` | Clé JWT staging |
| `PRODUCTION_JWT_SECRET` | `[généré précédemment]` | Clé JWT production |
| `STAGING_APP_KEY` | `[généré précédemment]` | Clé application Laravel staging |
| `PRODUCTION_APP_KEY` | `[généré précédemment]` | Clé application Laravel production |
| `VBG_ENCRYPTION_KEY_STAGING` | `[généré précédemment]` | Clé chiffrement données VBG staging |
| `VBG_ENCRYPTION_KEY_PRODUCTION` | `[généré précédemment]` | Clé chiffrement données VBG production |
| `SSH_PRIVATE_KEY` | `[clé SSH base64]` | Clé privée SSH pour déploiement |
| `HEALTH_CHECK_SECRET` | `[généré précédemment]` | Clé pour endpoints de santé |

#### 📧 SECRETS NOTIFICATIONS (optionnels pour tests)

| Nom du Secret | Valeur d'exemple | Description |
|---------------|------------------|-------------|
| `SLACK_WEBHOOK_URL` | `https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK` | Webhook Slack pour notifications |
| `DEPLOYMENT_WEBHOOK_URL` | `https://your-monitoring.com/webhook` | Webhook déploiement |

#### 🔧 SECRETS SERVICES EXTERNES (configurer selon besoins)

| Nom du Secret | Exemple | Description |
|---------------|---------|-------------|
| `TWILIO_SID` | `ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` | Twilio Account SID |
| `TWILIO_TOKEN` | `your_twilio_auth_token` | Token d'authentification Twilio |
| `TWILIO_FROM` | `+33123456789` | Numéro Twilio source |
| `GOOGLE_MAPS_API_KEY` | `AIzaxxxxxxxxxxxxxxxxxxxxxxxxxx` | Clé API Google Maps |
| `SENTRY_DSN` | `https://xxx@sentry.io/xxx` | DSN Sentry pour monitoring erreurs |

### Étape 3: Configurer les Variables Repository

Cliquer sur l'onglet **Variables** puis **New repository variable** :

| Nom de la Variable | Valeur |
|-------------------|--------|
| `NODE_VERSION` | `18` |
| `PHP_VERSION` | `8.1` |
| `FLUTTER_VERSION` | `3.13.9` |
| `STAGING_API_URL` | `https://staging-api.assistance-msaada.org` |
| `PRODUCTION_API_URL` | `https://api.assistance-msaada.org` |
| `COMPOSE_PROJECT_NAME` | `assistance-msaada` |

### Étape 4: Configurer les Environnements

1. Dans Settings, aller sur **Environments**
2. Créer deux environnements :

#### Environnement "staging"
- Cliquer **New environment**
- Nom: `staging`
- **Environment protection rules**: Aucune (déploiement automatique)

#### Environnement "production"  
- Cliquer **New environment**
- Nom: `production`
- **Environment protection rules**:
  - ✅ **Required reviewers**: Ajouter les administrateurs
  - ✅ **Wait timer**: 0 minutes
  - ✅ **Deployment branches**: Selected branches → `main`

---

## 🧪 VALIDATION DE LA CONFIGURATION

### Script de validation

Créer un fichier `validate-secrets.sh` :

```bash
#!/bin/bash

echo "🔍 Validation de la configuration des secrets GitHub..."

# Liste des secrets essentiels
required_secrets=(
    "STAGING_DB_PASSWORD"
    "PRODUCTION_DB_PASSWORD"
    "STAGING_JWT_SECRET"
    "PRODUCTION_JWT_SECRET"
    "STAGING_APP_KEY"
    "PRODUCTION_APP_KEY"
    "VBG_ENCRYPTION_KEY_STAGING"
    "VBG_ENCRYPTION_KEY_PRODUCTION"
    "SSH_PRIVATE_KEY"
    "HEALTH_CHECK_SECRET"
)

echo "📋 Secrets à vérifier dans GitHub:"
for secret in "${required_secrets[@]}"; do
    echo "  - $secret"
done

echo ""
echo "🔗 Pour vérifier:"
echo "1. Aller sur: https://github.com/sergenewton/assistance-msaada-2.0/settings/secrets/actions"
echo "2. Vérifier que tous les secrets ci-dessus sont configurés"
echo "3. Lancer un test du workflow GitHub Actions"

echo ""
echo "✅ Configuration minimale requise pour les tests locaux:"
echo "  - Les clés générées localement suffisent"
echo "  - Pas besoin de services externes pour le développement"
```

### Test du workflow

1. Créer un commit de test :
```bash
git add .
git commit -m "test: validate secrets configuration"
git push origin main
```

2. Aller sur l'onglet **Actions** du repository GitHub
3. Vérifier que le workflow se lance sans erreurs de secrets manquants

---

## 🏠 CONFIGURATION POUR DÉVELOPPEMENT LOCAL

Pour le développement local, vous n'avez besoin que des secrets essentiels. Les autres services peuvent être mocké ou désactivés.

### Secrets minimum pour développement :

```bash
# Dans backend-api/.env.development
APP_KEY=base64:$(openssl rand -base64 32)
JWT_SECRET=$(openssl rand -base64 32)
VBG_ENCRYPTION_KEY=$(openssl rand -hex 16)
DB_PASSWORD=password
HEALTH_CHECK_SECRET=$(openssl rand -hex 32)
```

### Variables recommandées :

```bash
# Services externes en mode développement
TWILIO_SID=test_sid
TWILIO_TOKEN=test_token
TWILIO_FROM=+33123456789
MAIL_MAILER=log
PUSHER_APP_KEY=local-key
PUSHER_APP_SECRET=local-secret
```

---

## 🚨 SÉCURITÉ ET BONNES PRATIQUES

### ✅ À faire :
- Utiliser des mots de passe forts et uniques
- Générer des clés aléatoirement avec OpenSSL
- Ne jamais committer de secrets dans le code
- Utiliser des environnements séparés pour staging/production
- Activer la protection sur l'environnement production

### ❌ À éviter :
- Réutiliser les mêmes clés entre environnements
- Utiliser des mots de passe faibles
- Partager les secrets par email ou Slack
- Stocker les secrets en plain text

### 🔄 Rotation des secrets :
- Renouveler les clés tous les 6 mois minimum
- Changer immédiatement si suspicion de compromission
- Documenter les changements de clés

---

## 📞 SUPPORT

En cas de problème avec la configuration :

1. **Erreurs de workflow** : Consulter l'onglet Actions sur GitHub
2. **Clés invalides** : Régénérer avec les commandes OpenSSL
3. **Permissions** : Vérifier les droits administrateur sur le repository
4. **Services externes** : Valider les comptes et quotas API

---

**Date de création** : 25 octobre 2025  
**Version** : 1.0  
**Repository** : https://github.com/sergenewton/assistance-msaada-2.0