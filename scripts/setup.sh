#!/bin/bash

# ===================================
# VBG Platform - Setup Script
# ===================================

set -e

echo "🚀 Configuration de l'environnement VBG Platform..."

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'affichage
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérifier les prérequis
check_requirements() {
    print_status "Vérification des prérequis..."
    
    # Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js n'est pas installé. Version requise: >= 18.0.0"
        exit 1
    fi
    
    # PHP  
    if ! command -v php &> /dev/null; then
        print_error "PHP n'est pas installé. Version requise: >= 8.1"
        exit 1
    fi
    
    # Composer
    if ! command -v composer &> /dev/null; then
        print_error "Composer n'est pas installé."
        exit 1
    fi
    
    # Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter n'est pas installé. Version requise: >= 3.13.0"
        exit 1
    fi
    
    print_success "Tous les prérequis sont satisfaits"
}

# Configuration Git et Conventional Commits
setup_git() {
    print_status "Configuration de Git et Conventional Commits..."
    
    # Installation des dépendances Node.js pour les hooks
    if [ -f "package.json" ]; then
        npm install
        npm run prepare  # Setup Husky hooks
        print_success "Git hooks configurés avec succès"
    fi
}

# Configuration du Backend Laravel
setup_backend() {
    print_status "Configuration du Backend Laravel..."
    
    cd backend-api
    
    # Installation des dépendances
    composer install --optimize-autoloader
    
    # Configuration environnement
    if [ ! -f ".env" ]; then
        cp .env.example .env
        php artisan key:generate
        php artisan jwt:secret
        print_warning "Pensez à configurer votre base de données dans .env"
    fi
    
    # Permissions
    chmod -R 775 storage bootstrap/cache
    
    cd ..
    print_success "Backend Laravel configuré"
}

# Configuration du Frontend React
setup_frontend() {
    print_status "Configuration du Frontend React..."
    
    cd frontend-web
    
    # Installation des dépendances
    npm install
    
    # Configuration environnement
    if [ ! -f ".env.local" ]; then
        echo "VITE_API_URL=http://localhost:8000/api/v1" > .env.local
        print_warning "Configurez les variables d'environnement dans .env.local"
    fi
    
    cd ..
    print_success "Frontend React configuré"
}

# Configuration de l'app Mobile Flutter
setup_mobile() {
    print_status "Configuration de l'application Mobile Flutter..."
    
    cd mobile-app
    
    # Installation des dépendances
    flutter pub get
    
    # Génération de code
    flutter pub run build_runner build --delete-conflicting-outputs
    
    cd ..
    print_success "Application Mobile Flutter configurée"
}

# Configuration Docker (optionnel)
setup_docker() {
    print_status "Configuration Docker..."
    
    if [ -f "docker-compose.yml" ]; then
        docker-compose up -d --build
        print_success "Services Docker démarrés"
    else
        print_warning "Fichier docker-compose.yml non trouvé"
    fi
}

# Menu principal
main_menu() {
    echo ""
    echo "🎯 Que souhaitez-vous configurer ?"
    echo "1) Configuration complète (recommandé)"
    echo "2) Backend seulement"  
    echo "3) Frontend seulement"
    echo "4) Mobile seulement"
    echo "5) Git/Commits seulement"
    echo "6) Docker seulement"
    echo "0) Quitter"
    echo ""
    
    read -p "Votre choix (0-6): " choice
    
    case $choice in
        1)
            check_requirements
            setup_git
            setup_backend
            setup_frontend
            setup_mobile
            ;;
        2)
            setup_backend
            ;;
        3)
            setup_frontend
            ;;
        4)
            setup_mobile
            ;;
        5)
            setup_git
            ;;
        6)
            setup_docker
            ;;
        0)
            echo "Au revoir!"
            exit 0
            ;;
        *)
            print_error "Choix invalide"
            main_menu
            ;;
    esac
}

# Affichage d'information post-installation
post_install_info() {
    echo ""
    echo "🎉 Configuration terminée avec succès!"
    echo ""
    echo "📋 Prochaines étapes:"
    echo "   1. Configurez votre base de données dans backend-api/.env"
    echo "   2. Lancez les migrations: cd backend-api && php artisan migrate --seed"
    echo "   3. Démarrez les services: ./scripts/dev.sh"
    echo ""
    echo "📚 Documentation:"
    echo "   - Guide Git: docs/GIT_STRATEGY.md"
    echo "   - Guide Commits: docs/COMMITS_GUIDE.md"
    echo "   - Architecture: docs/ARCHITECTURE.md"
    echo ""
    echo "🚀 Commandes utiles:"
    echo "   - Développement: ./scripts/dev.sh"
    echo "   - Tests: ./scripts/test.sh"
    echo "   - Build: ./scripts/build.sh"
    echo "   - Commit interactif: npm run commit"
    echo ""
}

# Exécution du script
echo "🚀 VBG Platform - Script de Configuration"
echo "======================================="

check_requirements
main_menu
post_install_info