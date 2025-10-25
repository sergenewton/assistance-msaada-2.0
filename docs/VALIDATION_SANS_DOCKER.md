# 🧪 GUIDE DE VALIDATION SANS DOCKER
## Assistance Msaada 2.0 - Tests de Configuration

Ce guide permet de valider la configuration du projet sans avoir Docker installé.

---

## 🎯 OBJECTIFS

- Vérifier la structure du projet
- Valider les fichiers de configuration
- Tester les dépendances individuellement
- Préparer l'environnement pour le déploiement

---

## 📋 VALIDATION DE LA STRUCTURE DU PROJET

### 1. Vérification des fichiers essentiels

```bash
# Se placer dans le répertoire du projet
cd "/Users/kashosichen/Documents/assistance msaada 2"

# Vérifier la présence des fichiers Docker
echo "🐳 Fichiers Docker :"
ls -la docker-compose*.yml | head -5

# Vérifier les fichiers d'environnement
echo -e "\n📝 Fichiers d'environnement :"
find . -name "*.env*" -not -path "./node_modules/*" | head -10

# Vérifier les scripts de déploiement
echo -e "\n🚀 Scripts de déploiement :"
ls -la deploy-*.sh
ls -la *.sh
```

### 2. Structure des services

```bash
# Vérifier l'architecture des services
echo "🏗️  Structure du projet :"
tree -d -L 2 . 2>/dev/null || find . -type d -maxdepth 2 | grep -E "(backend|frontend|mobile)" | head -10
```

---

## ⚙️ VALIDATION DES CONFIGURATIONS

### 1. Backend Laravel

```bash
# Vérifier les dépendances PHP
cd backend-api

echo "📦 Configuration Composer :"
if [ -f composer.json ]; then
    echo "✅ composer.json présent"
    cat composer.json | grep -E "(name|require)" | head -5
else
    echo "❌ composer.json manquant"
fi

# Vérifier la structure Laravel
echo -e "\n🏗️  Structure Laravel :"
ls -la | grep -E "(app|config|database|routes)"

# Vérifier les modèles
echo -e "\n📊 Modèles disponibles :"
ls -la Models/ | head -5

cd ..
```

### 2. Frontend React

```bash
# Vérifier les dépendances Node.js
cd frontend-web

echo "📦 Configuration npm :"
if [ -f package.json ]; then
    echo "✅ package.json présent"
    cat package.json | grep -E "(name|dependencies)" | head -5
else
    echo "❌ package.json manquant"
fi

# Vérifier la structure React
echo -e "\n🏗️  Structure React :"
ls -la src/ | head -5

cd ..
```

### 3. Mobile Flutter

```bash
# Vérifier la configuration Flutter
cd mobile-app

echo "📦 Configuration Flutter :"
if [ -f pubspec.yaml ]; then
    echo "✅ pubspec.yaml présent"
    cat pubspec.yaml | grep -E "(name|dependencies)" | head -5
else
    echo "❌ pubspec.yaml manquant"
fi

# Vérifier la structure Flutter
echo -e "\n🏗️  Structure Flutter :"
ls -la lib/ | head -5

cd ..
```

---

## 🔧 VALIDATION DES OUTILS DE DÉVELOPPEMENT

### 1. Vérification des outils installés

```bash
echo "🛠️  Outils de développement disponibles :"

# PHP
if command -v php &> /dev/null; then
    echo "✅ PHP $(php -v | head -1)"
else
    echo "❌ PHP non installé"
fi

# Node.js
if command -v node &> /dev/null; then
    echo "✅ Node.js $(node -v)"
else
    echo "❌ Node.js non installé"
fi

# Flutter
if command -v flutter &> /dev/null; then
    echo "✅ Flutter $(flutter --version | head -1)"
else
    echo "❌ Flutter non installé"
fi

# Git
if command -v git &> /dev/null; then
    echo "✅ Git $(git --version)"
else
    echo "❌ Git non installé"
fi

# Docker (optionnel pour validation)
if command -v docker &> /dev/null; then
    echo "✅ Docker $(docker --version)"
else
    echo "⚠️  Docker non installé (requis pour déploiement)"
fi
```

### 2. Tests des configurations

```bash
echo -e "\n🧪 Tests de configuration :"

# Test configuration Laravel
cd backend-api
if [ -f .env.development ]; then
    echo "✅ Configuration Laravel développement présente"
    echo "📋 Variables principales :"
    grep -E "(APP_NAME|DB_|REDIS_)" .env.development | head -5
else
    echo "❌ Configuration Laravel développement manquante"
fi
cd ..

# Test configuration React
cd frontend-web
if [ -f .env.development ]; then
    echo "✅ Configuration React développement présente"
    echo "📋 Variables principales :"
    grep -E "(VITE_)" .env.development | head -5
else
    echo "❌ Configuration React développement manquante"
fi
cd ..
```

---

## 🔍 VALIDATION DES SECRETS ET SÉCURITÉ

### 1. Vérification des clés de sécurité

```bash
echo "🔐 Validation des secrets :"

# Vérifier que les secrets ne sont pas commités
echo "🔍 Recherche de secrets potentiels dans le code :"
if grep -r -E "(password|secret|key)" --exclude-dir=node_modules --exclude-dir=vendor --include="*.php" --include="*.js" --include="*.ts" . | grep -v -E "(.env|config|example)" | head -3; then
    echo "⚠️  Secrets potentiels trouvés - à vérifier"
else
    echo "✅ Aucun secret en dur trouvé"
fi

# Vérifier les fichiers .env d'exemple
echo -e "\n📝 Fichiers d'exemple présents :"
find . -name "*.env.example" -o -name "*.env.development" | head -5
```

### 2. Test de génération des clés

```bash
echo -e "\n🔑 Test de génération des clés :"

# Tester OpenSSL
if command -v openssl &> /dev/null; then
    echo "✅ OpenSSL disponible"
    echo "🔑 Exemple de clé générée :"
    echo "JWT_SECRET=$(openssl rand -base64 32)"
else
    echo "❌ OpenSSL non disponible"
fi

# Tester SSH (pour déploiement)
if command -v ssh-keygen &> /dev/null; then
    echo "✅ SSH disponible pour génération de clés de déploiement"
else
    echo "❌ SSH non disponible"
fi
```

---

## 🌐 VALIDATION DES SERVICES EXTERNES

### 1. Test de connectivité

```bash
echo "🌐 Tests de connectivité :"

# Test de résolution DNS
if ping -c 1 google.com &> /dev/null; then
    echo "✅ Connectivité internet disponible"
else
    echo "❌ Pas de connectivité internet"
fi

# Test GitHub
if curl -s https://api.github.com/rate_limit &> /dev/null; then
    echo "✅ GitHub API accessible"
else
    echo "❌ GitHub API non accessible"
fi
```

### 2. Configuration CI/CD

```bash
echo -e "\n🔄 Configuration CI/CD :"

# Vérifier le workflow GitHub Actions
if [ -f .github/workflows/ci-cd.yml ]; then
    echo "✅ Workflow GitHub Actions présent"
    echo "📋 Événements configurés :"
    grep -E "(on:|push:|pull_request:)" .github/workflows/ci-cd.yml | head -3
else
    echo "❌ Workflow GitHub Actions manquant"
fi

# Vérifier la configuration Git
echo -e "\n📊 Configuration Git actuelle :"
git remote -v 2>/dev/null || echo "❌ Pas de remote configuré"
git branch --show-current 2>/dev/null || echo "❌ Pas de branche active"
```

---

## 📊 RAPPORT DE VALIDATION

### Script de rapport automatique

```bash
#!/bin/bash

echo "📊 =========================================="
echo "📊   RAPPORT DE VALIDATION - $(date)"
echo "📊 =========================================="

# Compter les fichiers par type
echo -e "\n📈 Statistiques du projet :"
echo "   📄 Fichiers PHP : $(find . -name "*.php" | wc -l)"
echo "   📄 Fichiers JS/TS : $(find . -name "*.js" -o -name "*.ts" -o -name "*.tsx" | wc -l)"
echo "   📄 Fichiers Dart : $(find . -name "*.dart" | wc -l)"
echo "   🐳 Fichiers Docker : $(find . -name "docker-compose*.yml" -o -name "Dockerfile*" | wc -l)"
echo "   ⚙️  Fichiers config : $(find . -name "*.env*" -o -name "*.config.*" -o -name "*.json" | wc -l)"

# État des services
echo -e "\n🔧 État des composants :"

components=("backend-api" "frontend-web" "mobile-app")
for comp in "${components[@]}"; do
    if [ -d "$comp" ]; then
        echo "   ✅ $comp : Présent"
    else
        echo "   ❌ $comp : Manquant"
    fi
done

# Recommandations
echo -e "\n💡 Recommandations :"
if ! command -v docker &> /dev/null; then
    echo "   🐳 Installer Docker pour les tests locaux"
fi

if [ ! -f backend-api/.env.development ]; then
    echo "   📝 Créer les fichiers d'environnement de développement"
fi

echo -e "\n✅ Validation terminée"
```

---

## 🚀 ÉTAPES SUIVANTES SANS DOCKER

### 1. Installation des dépendances individuelles

```bash
# Backend (si PHP installé)
cd backend-api
composer install --no-dev
cd ..

# Frontend (si Node.js installé)  
cd frontend-web
npm install
cd ..

# Mobile (si Flutter installé)
cd mobile-app
flutter pub get
cd ..
```

### 2. Tests unitaires (sans services externes)

```bash
# Tests PHP (sans base de données)
cd backend-api
if [ -f vendor/bin/phpunit ]; then
    echo "🧪 Tests PHP disponibles"
fi
cd ..

# Tests JavaScript
cd frontend-web
if [ -f node_modules/.bin/jest ]; then
    echo "🧪 Tests JavaScript disponibles"
fi
cd ..
```

### 3. Préparation pour le déploiement

1. **Installer Docker** : Pour le déploiement complet
2. **Configurer les secrets GitHub** : Utiliser le guide créé
3. **Tester avec le script deploy-development.sh** : Une fois Docker installé

---

## ✅ CHECKLIST DE VALIDATION

- [ ] Structure du projet vérifiée
- [ ] Fichiers de configuration présents
- [ ] Variables d'environnement configurées
- [ ] Scripts de déploiement créés
- [ ] Documentation des secrets disponible
- [ ] Workflow GitHub Actions configuré
- [ ] Remote Git configuré vers le repository

---

**Note** : Cette validation permet de s'assurer que le projet est correctement configuré avant l'installation de Docker et le déploiement complet.