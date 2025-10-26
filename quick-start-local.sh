#!/bin/bash

# Script de démarrage rapide Assistance Msaada 2.0
# Version développement locale (PHP + Vite)

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend-api"
FRONTEND_DIR="$SCRIPT_DIR/frontend-web"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Fonctions de logging
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] ✅ $1${NC}"; }
warn() { echo -e "${YELLOW}[$(date +'%H:%M:%S')] ⚠️  $1${NC}"; }
error() { echo -e "${RED}[$(date +'%H:%M:%S')] ❌ $1${NC}"; }
info() { echo -e "${BLUE}[$(date +'%H:%M:%S')] ℹ️  $1${NC}"; }
success() { echo -e "${PURPLE}[$(date +'%H:%M:%S')] 🎉 $1${NC}"; }
action() { echo -e "${CYAN}[$(date +'%H:%M:%S')] 🚀 $1${NC}"; }

# Banner
show_banner() {
    echo -e "${PURPLE}"
    cat << 'EOF'
    
 █████╗ ███████╗███████╗██╗███████╗████████╗ █████╗ ███╗   ██╗ ██████╗███████╗
██╔══██╗██╔════╝██╔════╝██║██╔════╝╚══██╔══╝██╔══██╗████╗  ██║██╔════╝██╔════╝
███████║███████╗███████╗██║███████╗   ██║   ███████║██╔██╗ ██║██║     █████╗  
██╔══██║╚════██║╚════██║██║╚════██║   ██║   ██╔══██║██║╚██╗██║██║     ██╔══╝  
██║  ██║███████║███████║██║███████║   ██║   ██║  ██║██║ ╚████║╚██████╗███████╗
╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝

███╗   ███╗███████╗ █████╗  █████╗ ██████╗  █████╗     ██████╗    ██████╗ 
████╗ ████║██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔══██╗    ╚════██╗  ██╔═████╗
██╔████╔██║███████╗███████║███████║██║  ██║███████║     █████╔╝  ██║██╔██║
██║╚██╔╝██║╚════██║██╔══██║██╔══██║██║  ██║██╔══██║    ██╔═══╝   ████╔╝██║
██║ ╚═╝ ██║███████║██║  ██║██║  ██║██████╔╝██║  ██║    ███████╗██╗╚██████╔╝
╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝    ╚══════╝╚═╝ ╚═════╝ 

    🏥 Plateforme de Gestion des Violences Basées sur le Genre
    🔒 Démarrage Local Rapide - Mode Développement
    
EOF
    echo -e "${NC}"
}

# Aide
show_help() {
    cat << EOF
🚀 Assistance Msaada 2.0 - Démarrage Local Rapide

Usage: $0 [OPTIONS]

Options:
    --backend-only      Démarrer uniquement l'API Backend (port 8000)
    --frontend-only     Démarrer uniquement le Frontend (port 3000)
    --stop              Arrêter tous les services
    --status            Vérifier le statut des services
    -h, --help          Afficher cette aide

Par défaut: Démarre Backend + Frontend

Exemples:
    $0                  # Démarrage complet
    $0 --backend-only   # API seulement
    $0 --frontend-only  # Frontend seulement
    $0 --stop           # Arrêt des services
    $0 --status         # Statut des services

EOF
}

# Vérification des prérequis
check_prerequisites() {
    action "Vérification des prérequis..."

    local missing_tools=()

    # PHP
    if ! command -v php &> /dev/null; then
        missing_tools+=("php")
    else
        local php_version=$(php -v | head -n1 | awk '{print $2}')
        log "PHP version: $php_version"
    fi

    # Node.js/npm
    if ! command -v node &> /dev/null; then
        missing_tools+=("node")
    else
        local node_version=$(node -v)
        log "Node.js version: $node_version"
    fi

    if ! command -v npm &> /dev/null; then
        missing_tools+=("npm")
    else
        local npm_version=$(npm -v)
        log "npm version: $npm_version"
    fi

    # Outils système
    for tool in curl jq; do
        if ! command -v $tool &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        error "Outils manquants: ${missing_tools[*]}"
        error "Veuillez installer ces outils avant de continuer"
        exit 1
    fi

    success "Prérequis vérifiés"
}

# Arrêt des services
stop_services() {
    action "Arrêt des services en cours..."

    # Arrêt des processus PHP
    pkill -f "php -S localhost:8000" 2>/dev/null || true
    pkill -f "api-test.php" 2>/dev/null || true

    # Arrêt des processus Node
    pkill -f "npm run dev" 2>/dev/null || true
    pkill -f "vite" 2>/dev/null || true

    sleep 2

    success "Services arrêtés"
}

# Démarrage du backend
start_backend() {
    action "Démarrage du backend API..."

    if ! cd "$BACKEND_DIR/public"; then
        error "Impossible d'accéder au répertoire backend: $BACKEND_DIR/public"
        return 1
    fi

    # Vérifier si api-test.php existe
    if [[ ! -f "api-test.php" ]]; then
        error "Fichier api-test.php non trouvé dans $BACKEND_DIR/public"
        return 1
    fi

    # Démarrer le serveur PHP en arrière-plan
    info "Démarrage du serveur PHP sur http://localhost:8000"
    php -S localhost:8000 api-test.php > /tmp/msaada-backend.log 2>&1 &
    local backend_pid=$!

    # Attendre que le serveur soit prêt
    local wait_time=0
    local max_wait=15
    while [[ $wait_time -lt $max_wait ]]; do
        if curl -s "http://localhost:8000/api/health" >/dev/null 2>&1; then
            success "Backend API démarré (PID: $backend_pid)"
            return 0
        fi
        sleep 1
        ((wait_time++))
    done

    error "Échec du démarrage du backend après ${max_wait}s"
    return 1
}

# Démarrage du frontend
start_frontend() {
    action "Démarrage du frontend..."

    if ! cd "$FRONTEND_DIR"; then
        error "Impossible d'accéder au répertoire frontend: $FRONTEND_DIR"
        return 1
    fi

    # Vérifier si package.json existe
    if [[ ! -f "package.json" ]]; then
        error "Fichier package.json non trouvé dans $FRONTEND_DIR"
        return 1
    fi

    # Installer les dépendances si nécessaire
    if [[ ! -d "node_modules" ]]; then
        info "Installation des dépendances npm..."
        npm install
    fi

    # Démarrer le serveur Vite en arrière-plan
    info "Démarrage du serveur Vite sur http://localhost:3000"
    npm run dev -- --host 0.0.0.0 > /tmp/msaada-frontend.log 2>&1 &
    local frontend_pid=$!

    # Attendre que le serveur soit prêt
    local wait_time=0
    local max_wait=30
    while [[ $wait_time -lt $max_wait ]]; do
        if curl -s "http://localhost:3000" >/dev/null 2>&1; then
            success "Frontend démarré (PID: $frontend_pid)"
            return 0
        fi
        sleep 1
        ((wait_time++))
    done

    error "Échec du démarrage du frontend après ${max_wait}s"
    return 1
}

# Vérification du statut
check_status() {
    action "Vérification du statut des services..."

    local backend_status="❌ Arrêté"
    local frontend_status="❌ Arrêté"

    # Check backend
    if curl -s --max-time 5 "http://localhost:8000/api/health" >/dev/null 2>&1; then
        backend_status="✅ Fonctionnel"
    fi

    # Check frontend
    if curl -s --max-time 5 "http://localhost:3000" >/dev/null 2>&1; then
        frontend_status="✅ Fonctionnel"
    fi

    echo ""
    info "📊 Statut des services:"
    echo -e "  🔧 Backend API (port 8000):  $backend_status"
    echo -e "  🎨 Frontend Web (port 3000): $frontend_status"
    echo ""

    # Test de connexion API
    if [[ "$backend_status" == "✅ Fonctionnel" ]]; then
        local api_response=$(curl -s "http://localhost:8000/api/health" | jq -r '.status' 2>/dev/null || echo "error")
        if [[ "$api_response" == "ok" ]]; then
            log "✓ API Health Check: OK"
        else
            warn "✗ API Health Check: Échec"
        fi

        # Test de l'authentification
        local auth_test=$(curl -s -X POST "http://localhost:8000/api/v1/auth/login" \
            -H "Content-Type: application/json" \
            -d '{"identifier":"survivor@example.com","password":"SecurePass123!"}' | \
            jq -r '.success' 2>/dev/null || echo "error")
        
        if [[ "$auth_test" == "true" ]]; then
            log "✓ Authentification API: OK"
        else
            warn "✗ Authentification API: Échec"
        fi
    fi
}

# Affichage des URLs et informations finales
show_final_info() {
    success "🎉 Assistance Msaada 2.0 opérationnel !"
    echo ""
    
    info "📊 URLs d'accès:"
    info "- Application Web: ${CYAN}http://localhost:3000${NC}"
    info "- API Backend: ${CYAN}http://localhost:8000/api${NC}"
    info "- Health Check: ${CYAN}http://localhost:8000/api/health${NC}"
    echo ""
    
    info "🔐 Identifiants de test:"
    info "- Email: ${YELLOW}survivor@example.com${NC}"
    info "- Mot de passe: ${YELLOW}SecurePass123!${NC}"
    echo ""
    
    info "📋 Commandes utiles:"
    info "- Arrêter les services: ${YELLOW}$0 --stop${NC}"
    info "- Vérifier le statut: ${YELLOW}$0 --status${NC}"
    info "- Voir les logs backend: ${YELLOW}tail -f /tmp/msaada-backend.log${NC}"
    info "- Voir les logs frontend: ${YELLOW}tail -f /tmp/msaada-frontend.log${NC}"
    echo ""
    
    warn "🔒 Notes de sécurité VBG:"
    warn "- Données sensibles anonymisées automatiquement"
    warn "- Mode développement - NE PAS utiliser en production"
    warn "- Changer les identifiants par défaut en production"
}

# Gestion d'interruption
cleanup_on_exit() {
    warn "\nInterruption détectée - Arrêt des services..."
    stop_services
    exit 1
}

trap cleanup_on_exit INT TERM

# Fonction principale
main() {
    local backend_only=false
    local frontend_only=false
    local stop_services_flag=false
    local status_only=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --backend-only)
                backend_only=true
                shift
                ;;
            --frontend-only)
                frontend_only=true
                shift
                ;;
            --stop)
                stop_services_flag=true
                shift
                ;;
            --status)
                status_only=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                error "Option inconnue: $1"
                show_help
                exit 1
                ;;
        esac
    done

    show_banner

    # Actions spéciales
    if [[ "$stop_services_flag" == "true" ]]; then
        stop_services
        exit 0
    fi

    if [[ "$status_only" == "true" ]]; then
        check_status
        exit 0
    fi

    # Démarrage normal
    check_prerequisites

    # Arrêter les services existants
    stop_services

    # Démarrer les services selon les options
    local services_started=0

    if [[ "$frontend_only" != "true" ]]; then
        if start_backend; then
            ((services_started++))
        else
            error "Échec du démarrage du backend"
            exit 1
        fi
    fi

    if [[ "$backend_only" != "true" ]]; then
        if start_frontend; then
            ((services_started++))
        else
            error "Échec du démarrage du frontend"
            exit 1
        fi
    fi

    # Vérifications finales
    sleep 3
    check_status
    
    if [[ $services_started -gt 0 ]]; then
        show_final_info
        success "Démarrage terminé - Système prêt ! 🚀"
    else
        error "Aucun service démarré"
        exit 1
    fi
}

# Point d'entrée
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi