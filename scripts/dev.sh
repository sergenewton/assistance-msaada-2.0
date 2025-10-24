#!/bin/bash

# ===================================
# VBG Platform - Development Script  
# ===================================

set -e

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[DEV]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Démarrer tous les services en développement
start_all() {
    print_status "Démarrage de tous les services de développement..."
    
    # Démarrer en arrière-plan
    trap 'kill $(jobs -p)' EXIT
    
    # Backend Laravel
    print_status "Démarrage du Backend (port 8000)..."
    cd backend-api && php artisan serve --port=8000 &
    BACKEND_PID=$!
    cd ..
    
    # Frontend React  
    print_status "Démarrage du Frontend (port 3000)..."
    cd frontend-web && npm run dev &
    FRONTEND_PID=$!
    cd ..
    
    # Attendre un peu pour que les services démarrent
    sleep 3
    
    print_success "Services démarrés!"
    echo ""
    echo "🌐 URLs disponibles:"
    echo "   • Backend API: http://localhost:8000"
    echo "   • Frontend Web: http://localhost:3000" 
    echo "   • Mobile: flutter run dans mobile-app/"
    echo ""
    echo "📱 Pour l'app mobile:"
    echo "   cd mobile-app && flutter run"
    echo ""
    echo "⏹️  Appuyez sur Ctrl+C pour arrêter tous les services"
    
    # Attendre l'interruption
    wait
}

# Démarrer seulement le backend
start_backend() {
    print_status "Démarrage du Backend seulement..."
    cd backend-api
    php artisan serve --port=8000
}

# Démarrer seulement le frontend
start_frontend() {
    print_status "Démarrage du Frontend seulement..."
    cd frontend-web  
    npm run dev
}

# Démarrer seulement le mobile
start_mobile() {
    print_status "Démarrage de l'app Mobile..."
    cd mobile-app
    flutter run
}

# Menu principal
main_menu() {
    echo "🚀 VBG Platform - Mode Développement"
    echo "===================================="
    echo ""
    echo "Que souhaitez-vous démarrer ?"
    echo "1) Tous les services (Backend + Frontend)"
    echo "2) Backend seulement (Laravel)"
    echo "3) Frontend seulement (React)"  
    echo "4) Mobile seulement (Flutter)"
    echo "0) Quitter"
    echo ""
    
    read -p "Votre choix (0-4): " choice
    
    case $choice in
        1)
            start_all
            ;;
        2)
            start_backend
            ;;
        3)
            start_frontend
            ;;
        4)
            start_mobile
            ;;
        0)
            echo "Au revoir!"
            exit 0
            ;;
        *)
            echo "Choix invalide"
            main_menu
            ;;
    esac
}

# Vérifier si nous sommes dans le bon répertoire
if [[ ! -f "package.json" || ! -d "backend-api" || ! -d "frontend-web" || ! -d "mobile-app" ]]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis la racine du projet VBG Platform"
    exit 1
fi

# Si aucun argument, montrer le menu
if [ $# -eq 0 ]; then
    main_menu
else
    case $1 in
        "all")
            start_all
            ;;
        "backend"|"api")
            start_backend
            ;;
        "frontend"|"web")
            start_frontend
            ;;
        "mobile"|"app")
            start_mobile
            ;;
        *)
            echo "Usage: $0 [all|backend|frontend|mobile]"
            exit 1
            ;;
    esac
fi