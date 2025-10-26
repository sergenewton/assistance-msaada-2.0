#!/bin/bash

# Script de démarrage rapide Assistance Msaada 2.0
# Version locale pour développement (PHP + Vite)

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration par défaut
ENVIRONMENT="development"
MODE="full"
SKIP_SENTRY_SETUP=false
SKIP_MONITORING=false
QUICK_START=false

# Logging avec style
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] ✅ $1${NC}"; }
warn() { echo -e "${YELLOW}[$(date +'%H:%M:%S')] ⚠️  $1${NC}"; }
error() { echo -e "${RED}[$(date +'%H:%M:%S')] ❌ $1${NC}"; }
info() { echo -e "${BLUE}[$(date +'%H:%M:%S')] ℹ️  $1${NC}"; }
success() { echo -e "${PURPLE}[$(date +'%H:%M:%S')] 🎉 $1${NC}"; }
action() { echo -e "${CYAN}[$(date +'%H:%M:%S')] 🚀 $1${NC}"; }

# ASCII Art pour le démarrage
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
    🔒 Démarrage Sécurisé avec Monitoring Avancé
    
EOF
    echo -e "${NC}"
}

# Fonction d'aide
show_help() {
    cat << EOF
🚀 Assistance Msaada 2.0 - Démarrage Rapide

Usage: $0 [OPTIONS]

Options:
    -e, --environment ENV          Environnement (development|staging|production)
    -m, --mode MODE               Mode de démarrage (full|backend|frontend|monitoring)
    -q, --quick                   Démarrage rapide (skip setup interactif)
    --skip-sentry                 Ignorer la configuration Sentry
    --skip-monitoring             Ignorer le monitoring (Grafana/Prometheus)
    -h, --help                    Afficher cette aide

Modes disponibles:
    full        - Démarrage complet (défaut)
    backend     - Backend Laravel uniquement
    frontend    - Frontend React uniquement  
    monitoring  - Monitoring stack uniquement

Exemples:
    $0                           # Démarrage complet interactif
    $0 -e staging -q            # Staging rapide
    $0 -m backend               # Backend seulement
    $0 -e production --skip-sentry  # Production sans Sentry

🔒 Sécurité VBG:
    - Sanitisation automatique des données sensibles
    - Monitoring spécialisé pour confidentialité
    - Alertes de sécurité en temps réel
    - Conformité RGPD intégrée

EOF
}

# Parsing des arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -e|--environment)
                ENVIRONMENT="$2"
                shift 2
                ;;
            -m|--mode)
                MODE="$2"
                shift 2
                ;;
            -q|--quick)
                QUICK_START=true
                shift
                ;;
            --skip-sentry)
                SKIP_SENTRY_SETUP=true
                shift
                ;;
            --skip-monitoring)
                SKIP_MONITORING=true
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

    # Validation
    if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
        error "Environnement invalide: $ENVIRONMENT"
        exit 1
    fi

    if [[ ! "$MODE" =~ ^(full|backend|frontend|monitoring)$ ]]; then
        error "Mode invalide: $MODE"
        exit 1
    fi
}

# Configuration interactive
interactive_setup() {
    if [[ "$QUICK_START" == "true" ]]; then
        return 0
    fi

    info "Configuration interactive d'Assistance Msaada 2.0"
    echo ""

    # Choix de l'environnement
    if [[ -z "$ENVIRONMENT" ]]; then
        echo "Sélectionnez l'environnement:"
        echo "1) Development (développement local)"
        echo "2) Staging (tests et validation)"
        echo "3) Production (environnement live)"
        echo ""
        read -p "Votre choix [1-3]: " env_choice
        
        case $env_choice in
            1) ENVIRONMENT="development" ;;
            2) ENVIRONMENT="staging" ;;
            3) ENVIRONMENT="production" ;;
            *) warn "Choix invalide, utilisation de 'development'"; ENVIRONMENT="development" ;;
        esac
    fi

    # Configuration Sentry
    if [[ "$SKIP_SENTRY_SETUP" == "false" ]]; then
        echo ""
        read -p "Configurer Sentry pour le monitoring des erreurs? [y/N]: " setup_sentry
        if [[ ! "$setup_sentry" =~ ^[Yy]$ ]]; then
            SKIP_SENTRY_SETUP=true
        fi
    fi

    # Configuration Monitoring
    if [[ "$SKIP_MONITORING" == "false" ]]; then
        echo ""
        read -p "Démarrer le monitoring (Grafana/Prometheus)? [Y/n]: " setup_monitoring
        if [[ "$setup_monitoring" =~ ^[Nn]$ ]]; then
            SKIP_MONITORING=true
        fi
    fi

    echo ""
    info "Configuration sélectionnée:"
    info "- Environnement: $ENVIRONMENT"
    info "- Mode: $MODE"
    info "- Sentry: $([ "$SKIP_SENTRY_SETUP" == "true" ] && echo "Non" || echo "Oui")"
    info "- Monitoring: $([ "$SKIP_MONITORING" == "true" ] && echo "Non" || echo "Oui")"
    echo ""
    
    read -p "Continuer avec cette configuration? [Y/n]: " confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        warn "Démarrage annulé"
        exit 0
    fi
}

# Vérification des prérequis
check_prerequisites() {
    action "Vérification des prérequis..."

    local missing_tools=()

    # Docker
    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    elif ! docker info &> /dev/null; then
        error "Docker n'est pas en cours d'exécution"
        exit 1
    fi

    # Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        missing_tools+=("docker-compose")
    fi

    # Node.js (pour le frontend)
    if [[ "$MODE" =~ ^(full|frontend)$ ]] && ! command -v node &> /dev/null; then
        missing_tools+=("node")
    fi

    # PHP/Composer (pour le backend)
    if [[ "$MODE" =~ ^(full|backend)$ ]] && ! command -v composer &> /dev/null; then
        missing_tools+=("composer")
    fi

    # Outils système
    for tool in curl wget jq; do
        if ! command -v $tool &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        error "Outils manquants: ${missing_tools[*]}"
        error "Veuillez installer ces outils avant de continuer"
        exit 1
    fi

    # Vérifier l'espace disque
    local available_space=$(df . | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 2097152 ]]; then # 2GB
        warn "Espace disque faible (${available_space}KB disponible)"
        read -p "Continuer malgré tout? [y/N]: " continue_anyway
        if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    success "Prérequis vérifiés"
}

# Configuration des variables d'environnement
setup_environment_variables() {
    action "Configuration des variables d'environnement..."

    local env_file="$PROJECT_ROOT/.env.$ENVIRONMENT"
    
    # Créer le fichier d'environnement s'il n'existe pas
    if [[ ! -f "$env_file" ]]; then
        info "Création du fichier $env_file"
        
        cat > "$env_file" << EOF
# Configuration Assistance Msaada 2.0 - $ENVIRONMENT
APP_ENV=$ENVIRONMENT
APP_DEBUG=$([ "$ENVIRONMENT" == "development" ] && echo "true" || echo "false")
APP_KEY=base64:$(openssl rand -base64 32)
APP_URL=http://localhost:8000

# Base de données
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=assistance_msaada
DB_USERNAME=msaada_user
DB_PASSWORD=$(openssl rand -base64 16)

# Redis
REDIS_HOST=redis
REDIS_PASSWORD=
REDIS_PORT=6379

# Monitoring et Sentry
SENTRY_DSN=
SENTRY_ENVIRONMENT=$ENVIRONMENT
SENTRY_SAMPLE_RATE=$([ "$ENVIRONMENT" == "production" ] && echo "0.1" || echo "1.0")

# VBG Spécifique
VBG_SENSITIVE_LOGGING=true
VBG_AUTO_ANONYMIZE=true
VBG_DATA_RETENTION_DAYS=30

# Sécurité
BCRYPT_ROUNDS=12
SESSION_LIFETIME=120
EOF
    fi

    # Exporter les variables pour Docker Compose
    export $(grep -v '^#' "$env_file" | xargs)
    
    success "Variables d'environnement configurées"
}

# Setup Sentry
setup_sentry() {
    if [[ "$SKIP_SENTRY_SETUP" == "true" ]]; then
        info "Configuration Sentry ignorée"
        return 0
    fi

    action "Configuration Sentry pour monitoring des erreurs..."

    # Exécuter le script de setup Sentry
    if [[ -f "$SCRIPT_DIR/setup-sentry.sh" ]]; then
        bash "$SCRIPT_DIR/setup-sentry.sh"
    else
        warn "Script setup-sentry.sh non trouvé, ignoré"
    fi

    success "Sentry configuré"
}

# Démarrage des services
start_services() {
    action "Démarrage des services ($MODE)..."

    local compose_file="$PROJECT_ROOT/docker-compose.${ENVIRONMENT}-advanced.yml"
    
    if [[ ! -f "$compose_file" ]]; then
        # Fallback sur le fichier de test si pas d'environnement spécifique
        compose_file="$PROJECT_ROOT/docker-compose.test.yml"
        warn "Utilisation du fichier de test: $compose_file"
    fi

    # Services à démarrer selon le mode
    local services_to_start=""
    
    case $MODE in
        "full")
            services_to_start=""  # Tous les services
            ;;
        "backend")
            services_to_start="mysql redis backend nginx"
            ;;
        "frontend")
            services_to_start="frontend"
            ;;
        "monitoring")
            if [[ "$SKIP_MONITORING" == "false" ]]; then
                services_to_start="prometheus grafana alertmanager"
            else
                warn "Monitoring désactivé"
                return 0
            fi
            ;;
    esac

    # Démarrage avec docker-compose
    info "Démarrage avec: docker-compose -f $compose_file up -d $services_to_start"
    
    if docker-compose -f "$compose_file" up -d $services_to_start; then
        success "Services démarrés avec succès"
    else
        error "Échec du démarrage des services"
        return 1
    fi

    # Attendre que les services soient prêts
    wait_for_services
}

# Attendre que les services soient disponibles
wait_for_services() {
    action "Vérification de la disponibilité des services..."

    local max_wait=120
    local wait_time=0
    local check_interval=5

    # Services à vérifier selon le mode
    case $MODE in
        "full"|"backend")
            # Attendre MySQL
            info "Attente de MySQL..."
            while ! docker exec msaada-mysql mysqladmin ping -h localhost --silent 2>/dev/null; do
                if [[ $wait_time -ge $max_wait ]]; then
                    error "Timeout: MySQL non disponible après ${max_wait}s"
                    return 1
                fi
                sleep $check_interval
                ((wait_time += check_interval))
            done
            
            # Attendre Redis
            info "Attente de Redis..."
            wait_time=0
            while ! docker exec msaada-redis redis-cli ping 2>/dev/null | grep -q "PONG"; do
                if [[ $wait_time -ge $max_wait ]]; then
                    error "Timeout: Redis non disponible après ${max_wait}s"
                    return 1
                fi
                sleep $check_interval
                ((wait_time += check_interval))
            done

            # Attendre l'API Backend
            info "Attente de l'API Backend..."
            wait_time=0
            while ! curl -s --max-time 5 "http://localhost:8000/api/health" >/dev/null 2>&1; do
                if [[ $wait_time -ge $max_wait ]]; then
                    warn "API Backend non disponible (peut être normal lors du premier démarrage)"
                    break
                fi
                sleep $check_interval
                ((wait_time += check_interval))
            done
            ;;
    esac

    success "Services disponibles"
}

# Vérification post-démarrage
post_startup_checks() {
    action "Vérification post-démarrage..."

    local checks_passed=0
    local total_checks=0

    case $MODE in
        "full"|"backend")
            # Check MySQL
            ((total_checks++))
            if docker exec msaada-mysql mysqladmin ping -h localhost --silent 2>/dev/null; then
                log "✓ MySQL opérationnel"
                ((checks_passed++))
            else
                warn "✗ MySQL non responsive"
            fi

            # Check Redis
            ((total_checks++))
            if docker exec msaada-redis redis-cli ping 2>/dev/null | grep -q "PONG"; then
                log "✓ Redis opérationnel"
                ((checks_passed++))
            else
                warn "✗ Redis non responsive"
            fi

            # Check API (optionnel)
            ((total_checks++))
            if curl -s --max-time 10 "http://localhost:8000/api/health" >/dev/null 2>&1; then
                log "✓ API Backend accessible"
                ((checks_passed++))
            else
                warn "✗ API Backend non accessible (normal si premier démarrage)"
            fi
            ;;
    esac

    case $MODE in
        "full"|"frontend")
            # Check Frontend
            ((total_checks++))
            if curl -s --max-time 10 "http://localhost:3000" >/dev/null 2>&1; then
                log "✓ Frontend accessible"
                ((checks_passed++))
            else
                warn "✗ Frontend non accessible"
            fi
            ;;
    esac

    if [[ "$SKIP_MONITORING" == "false" ]]; then
        case $MODE in
            "full"|"monitoring")
                # Check Grafana
                ((total_checks++))
                if curl -s --max-time 10 "http://localhost:3001" >/dev/null 2>&1; then
                    log "✓ Grafana accessible"
                    ((checks_passed++))
                else
                    warn "✗ Grafana non accessible"
                fi

                # Check Prometheus
                ((total_checks++))
                if curl -s --max-time 10 "http://localhost:9090" >/dev/null 2>&1; then
                    log "✓ Prometheus accessible"
                    ((checks_passed++))
                else
                    warn "✗ Prometheus non accessible"
                fi
                ;;
        esac
    fi

    local success_rate=$((checks_passed * 100 / total_checks))
    
    if [[ $success_rate -ge 70 ]]; then
        success "Vérifications réussies ($checks_passed/$total_checks - $success_rate%)"
        return 0
    else
        warn "Certaines vérifications ont échoué ($checks_passed/$total_checks - $success_rate%)"
        return 1
    fi
}

# Affichage des informations finales
show_final_info() {
    success "🎉 Assistance Msaada 2.0 démarré avec succès !"
    echo ""
    
    info "📊 URLs d'accès:"
    case $MODE in
        "full"|"frontend")
            info "- Application Web: ${CYAN}http://localhost:3000${NC}"
            ;;
    esac
    
    case $MODE in
        "full"|"backend")
            info "- API Backend: ${CYAN}http://localhost:8000/api${NC}"
            info "- Health Check: ${CYAN}http://localhost:8000/api/health${NC}"
            ;;
    esac

    if [[ "$SKIP_MONITORING" == "false" ]]; then
        case $MODE in
            "full"|"monitoring")
                info "- Grafana Dashboard: ${CYAN}http://localhost:3001${NC} (admin/admin)"
                info "- Prometheus: ${CYAN}http://localhost:9090${NC}"
                info "- AlertManager: ${CYAN}http://localhost:9093${NC}"
                ;;
        esac
    fi

    echo ""
    info "📋 Commandes utiles:"
    info "- Voir les logs: ${YELLOW}docker-compose logs -f${NC}"
    info "- Arrêter les services: ${YELLOW}docker-compose down${NC}"
    info "- Redémarrer: ${YELLOW}$0 -e $ENVIRONMENT -q${NC}"
    
    echo ""
    info "📚 Documentation:"
    info "- Guide Sentry VBG: ${CYAN}docs/SENTRY_VBG_GUIDE.md${NC}"
    info "- Architecture: ${CYAN}mobile-app/ARCHITECTURE.md${NC}"
    
    echo ""
    warn "🔒 Sécurité VBG:"
    warn "- Les données sensibles sont automatiquement anonymisées"
    warn "- Monitoring de sécurité actif"
    warn "- Conformité RGPD intégrée"
    
    echo ""
    info "🚀 Prochaines étapes:"
    info "1. Configurer vos DSN Sentry dans les fichiers .env"
    info "2. Personnaliser les dashboards Grafana"
    info "3. Tester les fonctionnalités VBG critiques"
    info "4. Configurer les alertes de sécurité"
}

# Gestion d'erreurs et cleanup
cleanup_on_exit() {
    warn "Interruption détectée - Nettoyage en cours..."
    docker-compose -f "$PROJECT_ROOT/docker-compose.${ENVIRONMENT}-advanced.yml" down 2>/dev/null || true
    exit 1
}

trap cleanup_on_exit INT TERM

# Fonction principale
main() {
    show_banner
    
    parse_arguments "$@"
    interactive_setup
    check_prerequisites
    setup_environment_variables
    
    if [[ "$SKIP_SENTRY_SETUP" == "false" ]]; then
        setup_sentry
    fi
    
    start_services
    post_startup_checks
    show_final_info

    success "Démarrage terminé - Système opérationnel ! 🚀"
}

# Point d'entrée
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi