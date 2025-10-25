#!/bin/bash

# =============================================================================
# 🚀 ASSISTANCE MSAADA 2.0 - DÉPLOIEMENT DÉVELOPPEMENT
# =============================================================================
# Script de déploiement pour l'environnement de développement local
# Auteur: DevOps Team
# Version: 1.0
# Date: 25 octobre 2025
# =============================================================================

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="assistance-msaada"
ENVIRONMENT="development"
LOG_FILE="$SCRIPT_DIR/logs/deploy-${ENVIRONMENT}-$(date +%Y%m%d_%H%M%S).log"
BACKUP_DIR="$SCRIPT_DIR/backups/dev"

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# 📋 FONCTIONS UTILITAIRES
# =============================================================================

# Fonction de logging
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$LOG_FILE"
}

# Messages colorés
info() { log "INFO" "${BLUE}$1${NC}"; }
success() { log "SUCCESS" "${GREEN}$1${NC}"; }
warning() { log "WARNING" "${YELLOW}$1${NC}"; }
error() { log "ERROR" "${RED}$1${NC}"; }

# Vérification des prérequis
check_prerequisites() {
    info "🔍 Vérification des prérequis..."
    
    # Vérifier Docker
    if ! command -v docker &> /dev/null; then
        error "❌ Docker n'est pas installé"
        exit 1
    fi
    
    # Vérifier Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        error "❌ Docker Compose n'est pas installé"
        exit 1
    fi
    
    # Vérifier les fichiers de configuration
    if [[ ! -f "docker-compose.development.yml" ]]; then
        error "❌ Fichier docker-compose.development.yml manquant"
        exit 1
    fi
    
    if [[ ! -f "backend-api/.env.development" ]]; then
        warning "⚠️  Fichier .env.development manquant dans backend-api"
        info "📝 Création d'un fichier .env.development basique..."
        create_env_development
    fi
    
    success "✅ Prérequis validés"
}

# Créer un fichier .env.development basique
create_env_development() {
    cat > backend-api/.env.development << EOF
# Application
APP_NAME="Assistance Msaada 2.0"
APP_ENV=development
APP_KEY=base64:$(openssl rand -base64 32)
APP_DEBUG=true
APP_URL=http://localhost:8000

# Base de données
DB_CONNECTION=mysql
DB_HOST=db-dev
DB_PORT=3306
DB_DATABASE=assistance_msaada_dev
DB_USERNAME=assistance_user
DB_PASSWORD=dev_password_123

# Cache et Sessions
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

# Redis
REDIS_HOST=redis-dev
REDIS_PASSWORD=null
REDIS_PORT=6379

# JWT
JWT_SECRET=$(openssl rand -base64 32)

# VBG Security
VBG_ENCRYPTION_KEY=$(openssl rand -hex 16)
HEALTH_CHECK_SECRET=$(openssl rand -hex 32)

# Mail (log pour développement)
MAIL_MAILER=log

# Services externes (mode test)
TWILIO_SID=test_sid
TWILIO_TOKEN=test_token
TWILIO_FROM=+33123456789

# Monitoring
LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug
EOF
    success "✅ Fichier .env.development créé"
}

# Nettoyer l'environnement
cleanup() {
    info "🧹 Nettoyage de l'environnement..."
    
    # Arrêter les conteneurs existants
    docker-compose -f docker-compose.development.yml down --remove-orphans || true
    
    # Supprimer les volumes orphelins (optionnel)
    if [[ "${1:-}" == "--clean" ]]; then
        warning "🗑️  Suppression des volumes de données..."
        docker volume prune -f || true
        docker-compose -f docker-compose.development.yml down -v || true
    fi
    
    success "✅ Nettoyage terminé"
}

# Créer les répertoires nécessaires
setup_directories() {
    info "📁 Création des répertoires..."
    
    mkdir -p logs
    mkdir -p backups/dev
    mkdir -p storage/app/public
    mkdir -p storage/logs
    
    success "✅ Répertoires créés"
}

# Construire les images Docker
build_images() {
    info "🔨 Construction des images Docker..."
    
    # Construire avec cache
    docker-compose -f docker-compose.development.yml build --parallel
    
    success "✅ Images construites"
}

# Démarrer les services
start_services() {
    info "🚀 Démarrage des services..."
    
    # Démarrer les services de base (database, redis)
    info "📊 Démarrage de la base de données et Redis..."
    docker-compose -f docker-compose.development.yml up -d db-dev redis-dev
    
    # Attendre que les services soient prêts
    info "⏳ Attente de la disponibilité des services..."
    sleep 10
    
    # Vérifier la base de données
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker-compose -f docker-compose.development.yml exec -T db-dev mysql -u assistance_user -pdev_password_123 -e "SELECT 1" > /dev/null 2>&1; then
            success "✅ Base de données prête"
            break
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            error "❌ Impossible de se connecter à la base de données"
            exit 1
        fi
        
        info "⏳ Tentative $attempt/$max_attempts - Attente de la base de données..."
        sleep 2
        ((attempt++))
    done
    
    # Démarrer l'application backend
    info "🔧 Démarrage du backend..."
    docker-compose -f docker-compose.development.yml up -d backend-dev
    
    success "✅ Services démarrés"
}

# Initialiser la base de données
init_database() {
    info "🗄️  Initialisation de la base de données..."
    
    # Attendre que le backend soit prêt
    sleep 15
    
    # Exécuter les migrations
    info "📝 Exécution des migrations..."
    docker-compose -f docker-compose.development.yml exec -T backend-dev php artisan migrate:fresh --seed --force
    
    # Créer le lien de stockage
    info "🔗 Création du lien de stockage..."
    docker-compose -f docker-compose.development.yml exec -T backend-dev php artisan storage:link
    
    success "✅ Base de données initialisée"
}

# Démarrer le frontend
start_frontend() {
    info "🎨 Démarrage du frontend..."
    
    # Créer le fichier .env.development pour le frontend si nécessaire
    if [[ ! -f "frontend-web/.env.development" ]]; then
        cat > frontend-web/.env.development << EOF
VITE_APP_NAME="Assistance Msaada 2.0"
VITE_APP_ENV=development
VITE_API_URL=http://localhost:8000
VITE_WS_URL=ws://localhost:6001
VITE_APP_DEBUG=true
VITE_FEATURE_REPORTING=true
VITE_FEATURE_CHAT=true
VITE_FEATURE_NOTIFICATIONS=true
VITE_GOOGLE_MAPS_API_KEY=demo_key
EOF
    fi
    
    docker-compose -f docker-compose.development.yml up -d frontend-dev
    
    success "✅ Frontend démarré"
}

# Vérifier le déploiement
verify_deployment() {
    info "🔍 Vérification du déploiement..."
    
    local services=("db-dev" "redis-dev" "backend-dev" "frontend-dev")
    local failed_services=()
    
    for service in "${services[@]}"; do
        if docker-compose -f docker-compose.development.yml ps "$service" | grep -q "Up"; then
            success "✅ $service: En fonctionnement"
        else
            error "❌ $service: Échec"
            failed_services+=("$service")
        fi
    done
    
    if [ ${#failed_services[@]} -eq 0 ]; then
        success "🎉 Déploiement réussi !"
        display_info
    else
        error "❌ Déploiement échoué pour: ${failed_services[*]}"
        info "📋 Vérifiez les logs avec: docker-compose -f docker-compose.development.yml logs [service]"
        exit 1
    fi
}

# Afficher les informations de connexion
display_info() {
    echo ""
    echo "🌟 =============================================="
    echo "🌟   ASSISTANCE MSAADA 2.0 - DÉVELOPPEMENT"
    echo "🌟 =============================================="
    echo ""
    echo "🔗 URLs d'accès :"
    echo "   📱 Frontend: http://localhost:3000"
    echo "   🔧 API Backend: http://localhost:8000"
    echo "   📊 Health Check: http://localhost:8000/health"
    echo ""
    echo "🗄️  Base de données :"
    echo "   🏠 Host: localhost:3306"
    echo "   👤 Utilisateur: assistance_user"
    echo "   🔑 Mot de passe: dev_password_123"
    echo "   📚 Base: assistance_msaada_dev"
    echo ""
    echo "📊 Redis :"
    echo "   🏠 Host: localhost:6379"
    echo ""
    echo "🛠️  Commandes utiles :"
    echo "   📋 Logs: docker-compose -f docker-compose.development.yml logs -f"
    echo "   ⏹️  Arrêter: docker-compose -f docker-compose.development.yml down"
    echo "   🔄 Redémarrer: ./deploy-development.sh"
    echo "   🧹 Nettoyer: ./deploy-development.sh --clean"
    echo ""
    echo "📁 Logs disponibles dans: $LOG_FILE"
    echo ""
}

# Fonction de rollback en cas d'erreur
rollback() {
    error "🔄 Rollback en cours..."
    docker-compose -f docker-compose.development.yml down
    error "❌ Déploiement échoué - Services arrêtés"
    exit 1
}

# =============================================================================
# 🎯 FONCTION PRINCIPALE
# =============================================================================

main() {
    echo "🚀 =============================================="
    echo "🚀   DÉPLOIEMENT DÉVELOPPEMENT - ASSISTANCE MSAADA 2.0"
    echo "🚀 =============================================="
    echo ""
    
    # Gérer les paramètres
    local clean_option=""
    if [[ "${1:-}" == "--clean" ]]; then
        clean_option="--clean"
    fi
    
    # Trap pour gérer les erreurs
    trap rollback ERR
    
    # Exécution des étapes
    check_prerequisites
    setup_directories
    cleanup "$clean_option"
    build_images
    start_services
    init_database
    start_frontend
    verify_deployment
    
    # Supprimer le trap
    trap - ERR
    
    success "🎉 Déploiement de développement terminé avec succès !"
}

# =============================================================================
# 🎬 EXÉCUTION
# =============================================================================

# Vérifier si le script est exécuté directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi