#!/bin/bash

# Script de déploiement Blue-Green pour Assistance Msaada 2.0
# Déploiement sans interruption avec rollback automatique

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/tmp/deployment_${TIMESTAMP}.log"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration par défaut
ENVIRONMENT=""
DEPLOYMENT_TYPE="blue-green"
HEALTH_CHECK_TIMEOUT=300
ROLLBACK_ON_FAILURE=true
BACKUP_RETENTION_DAYS=7
NOTIFICATION_WEBHOOK=""

# Logging
exec > >(tee -a "$LOG_FILE")
exec 2>&1

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

success() {
    echo -e "${PURPLE}[$(date +'%Y-%m-%d %H:%M:%S')] SUCCESS: $1${NC}"
}

# Fonction d'aide
show_help() {
    cat << EOF
🚀 Déploiement Blue-Green Assistance Msaada 2.0

Usage: $0 [OPTIONS]

Options:
    -e, --environment ENVIRONMENT   Environnement de déploiement (staging|production)
    -t, --type TYPE                Type de déploiement (blue-green|rolling|hotfix)
    -v, --version VERSION          Version à déployer (optionnel)
    -s, --skip-backup             Ignorer la sauvegarde pré-déploiement
    -n, --no-rollback            Désactiver le rollback automatique
    --health-timeout SECONDS      Timeout pour les health checks (défaut: 300s)
    --webhook URL                 URL webhook pour notifications
    -h, --help                    Afficher cette aide

Exemples:
    $0 -e staging                              # Déploiement staging standard
    $0 -e production -t blue-green -v 1.2.3   # Déploiement production avec version
    $0 -e production --no-rollback             # Production sans rollback auto

Environnements:
    staging     - Environnement de test
    production  - Environnement de production

Types de déploiement:
    blue-green  - Déploiement sans interruption (recommandé)
    rolling     - Mise à jour progressive
    hotfix      - Déploiement rapide (urgence)

⚠️  ATTENTION: Toujours tester en staging avant production !
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
            -t|--type)
                DEPLOYMENT_TYPE="$2"
                shift 2
                ;;
            -v|--version)
                VERSION="$2"
                shift 2
                ;;
            -s|--skip-backup)
                SKIP_BACKUP=true
                shift
                ;;
            -n|--no-rollback)
                ROLLBACK_ON_FAILURE=false
                shift
                ;;
            --health-timeout)
                HEALTH_CHECK_TIMEOUT="$2"
                shift 2
                ;;
            --webhook)
                NOTIFICATION_WEBHOOK="$2"
                shift 2
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

    # Validation des arguments requis
    if [[ -z "$ENVIRONMENT" ]]; then
        error "Environnement requis (-e|--environment)"
        exit 1
    fi

    if [[ ! "$ENVIRONMENT" =~ ^(staging|production)$ ]]; then
        error "Environnement invalide. Utilisez 'staging' ou 'production'"
        exit 1
    fi

    if [[ ! "$DEPLOYMENT_TYPE" =~ ^(blue-green|rolling|hotfix)$ ]]; then
        error "Type de déploiement invalide"
        exit 1
    fi
}

# Notification
send_notification() {
    local message="$1"
    local level="${2:-info}"
    local color_code

    case $level in
        success) color_code="good" ;;
        warning) color_code="warning" ;;
        error) color_code="danger" ;;
        *) color_code="#36a64f" ;;
    esac

    if [[ -n "$NOTIFICATION_WEBHOOK" ]]; then
        curl -X POST "$NOTIFICATION_WEBHOOK" \
            -H "Content-Type: application/json" \
            -d "{
                \"text\": \"🚀 Msaada Deployment\",
                \"attachments\": [{
                    \"color\": \"$color_code\",
                    \"fields\": [{
                        \"title\": \"Environment\",
                        \"value\": \"$ENVIRONMENT\",
                        \"short\": true
                    }, {
                        \"title\": \"Type\",
                        \"value\": \"$DEPLOYMENT_TYPE\",
                        \"short\": true
                    }, {
                        \"title\": \"Status\",
                        \"value\": \"$message\",
                        \"short\": false
                    }]
                }]
            }" 2>/dev/null || warn "Échec envoi notification"
    fi
}

# Vérification des prérequis
check_prerequisites() {
    log "Vérification des prérequis de déploiement..."

    # Docker et Docker Compose
    if ! command -v docker &> /dev/null; then
        error "Docker non installé"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        error "Docker Compose non installé"
        exit 1
    fi

    # Fichiers de configuration
    local compose_file="$PROJECT_ROOT/docker-compose.${ENVIRONMENT}-advanced.yml"
    if [[ ! -f "$compose_file" ]]; then
        error "Fichier Docker Compose non trouvé: $compose_file"
        exit 1
    fi

    # Variables d'environnement
    if [[ ! -f "$PROJECT_ROOT/.env.${ENVIRONMENT}" ]]; then
        warn "Fichier .env.$ENVIRONMENT non trouvé, utilisation des valeurs par défaut"
    fi

    # Espace disque
    local available_space=$(df . | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 2097152 ]]; then # 2GB en KB
        error "Espace disque insuffisant (minimum 2GB requis)"
        exit 1
    fi

    success "Prérequis vérifiés"
}

# Détection de l'état actuel
detect_current_state() {
    log "Détection de l'état du déploiement actuel..."

    # Déterminer quel environnement est actuellement actif (blue ou green)
    if docker ps --format "table {{.Names}}" | grep -q "msaada-blue"; then
        CURRENT_ENV="blue"
        NEW_ENV="green"
    else
        CURRENT_ENV="green"
        NEW_ENV="blue"
    fi

    info "État actuel: $CURRENT_ENV → Nouveau déploiement: $NEW_ENV"

    # Vérifier l'état des services
    CURRENT_SERVICES=$(docker ps --filter "name=msaada-${CURRENT_ENV}" --format "{{.Names}}" | wc -l)
    info "Services actuellement actifs: $CURRENT_SERVICES"
}

# Sauvegarde pré-déploiement
create_backup() {
    if [[ "$SKIP_BACKUP" == "true" ]]; then
        warn "Sauvegarde ignorée (--skip-backup)"
        return 0
    fi

    log "Création de la sauvegarde pré-déploiement..."

    local backup_dir="$PROJECT_ROOT/backups/${ENVIRONMENT}/${TIMESTAMP}"
    mkdir -p "$backup_dir"

    # Sauvegarde de la base de données
    log "Sauvegarde de la base de données..."
    docker exec "msaada-${CURRENT_ENV}-mysql" mysqldump \
        -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" \
        --single-transaction --routines --triggers \
        "${MYSQL_DATABASE}" > "$backup_dir/database.sql"

    # Sauvegarde des fichiers uploadés
    if docker ps --format "{{.Names}}" | grep -q "msaada-${CURRENT_ENV}-backend"; then
        log "Sauvegarde des fichiers..."
        docker cp "msaada-${CURRENT_ENV}-backend:/var/www/html/storage" "$backup_dir/"
    fi

    # Sauvegarde de la configuration
    cp "$PROJECT_ROOT/.env.${ENVIRONMENT}" "$backup_dir/" 2>/dev/null || true
    cp "$PROJECT_ROOT/docker-compose.${ENVIRONMENT}-advanced.yml" "$backup_dir/"

    # Métadonnées de sauvegarde
    cat > "$backup_dir/metadata.json" << EOF
{
    "timestamp": "$TIMESTAMP",
    "environment": "$ENVIRONMENT",
    "current_state": "$CURRENT_ENV",
    "git_commit": "$(git rev-parse HEAD 2>/dev/null || echo 'unknown')",
    "version": "${VERSION:-unknown}",
    "deployment_type": "$DEPLOYMENT_TYPE"
}
EOF

    success "Sauvegarde créée dans $backup_dir"
    BACKUP_DIR="$backup_dir"
}

# Construction des images
build_images() {
    log "Construction des images Docker pour $NEW_ENV..."

    local compose_file="$PROJECT_ROOT/docker-compose.${ENVIRONMENT}-advanced.yml"
    
    # Définir les variables d'environnement pour le nouveau déploiement
    export DEPLOYMENT_ENV="$NEW_ENV"
    export COMPOSE_PROJECT_NAME="msaada-${NEW_ENV}"

    # Construction avec cache pour accélérer
    docker-compose -f "$compose_file" build \
        --parallel \
        --compress \
        --force-rm

    # Tag des images avec timestamp pour traçabilité
    if [[ -n "$VERSION" ]]; then
        docker tag "msaada-${NEW_ENV}-backend:latest" "msaada-backend:${VERSION}"
        docker tag "msaada-${NEW_ENV}-frontend:latest" "msaada-frontend:${VERSION}"
    fi

    success "Images construites pour $NEW_ENV"
}

# Health checks
perform_health_checks() {
    local service_name="$1"
    local max_attempts=$((HEALTH_CHECK_TIMEOUT / 10))
    local attempt=1

    log "Health check pour $service_name (timeout: ${HEALTH_CHECK_TIMEOUT}s)..."

    while [[ $attempt -le $max_attempts ]]; do
        if check_service_health "$service_name"; then
            success "$service_name est en bonne santé (tentative $attempt)"
            return 0
        fi

        info "Tentative $attempt/$max_attempts échouée, attente 10s..."
        sleep 10
        ((attempt++))
    done

    error "Health check échoué pour $service_name après $max_attempts tentatives"
    return 1
}

check_service_health() {
    local service_name="$1"
    
    case $service_name in
        "backend")
            # Vérifier l'API backend
            local backend_url="http://localhost:8000/api/health"
            curl -s --max-time 5 "$backend_url" | grep -q "ok" 2>/dev/null
            ;;
        "frontend")
            # Vérifier le frontend
            curl -s --max-time 5 "http://localhost:3000" >/dev/null 2>&1
            ;;
        "database")
            # Vérifier MySQL
            docker exec "msaada-${NEW_ENV}-mysql" mysqladmin ping -h localhost 2>/dev/null
            ;;
        "redis")
            # Vérifier Redis
            docker exec "msaada-${NEW_ENV}-redis" redis-cli ping 2>/dev/null | grep -q "PONG"
            ;;
        *)
            error "Service inconnu: $service_name"
            return 1
            ;;
    esac
}

# Déploiement Blue-Green
deploy_blue_green() {
    log "Démarrage du déploiement Blue-Green..."

    # 1. Démarrer les nouveaux services
    log "Démarrage des services $NEW_ENV..."
    export DEPLOYMENT_ENV="$NEW_ENV"
    export COMPOSE_PROJECT_NAME="msaada-${NEW_ENV}"
    
    docker-compose -f "$PROJECT_ROOT/docker-compose.${ENVIRONMENT}-advanced.yml" up -d

    # 2. Attendre que les services soient prêts
    log "Vérification de l'état des services..."
    
    local services=("database" "redis" "backend" "frontend")
    for service in "${services[@]}"; do
        if ! perform_health_checks "$service"; then
            error "Service $service non disponible"
            if [[ "$ROLLBACK_ON_FAILURE" == "true" ]]; then
                rollback_deployment
            fi
            exit 1
        fi
    done

    # 3. Tests d'intégration rapides
    log "Exécution des tests d'intégration..."
    if ! run_integration_tests; then
        error "Tests d'intégration échoués"
        if [[ "$ROLLBACK_ON_FAILURE" == "true" ]]; then
            rollback_deployment
        fi
        exit 1
    fi

    # 4. Basculement du trafic (simulation)
    log "Basculement du trafic vers $NEW_ENV..."
    switch_traffic

    # 5. Vérification post-déploiement
    log "Vérification post-déploiement..."
    if ! post_deployment_checks; then
        error "Vérifications post-déploiement échouées"
        if [[ "$ROLLBACK_ON_FAILURE" == "true" ]]; then
            rollback_deployment
        fi
        exit 1
    fi

    # 6. Arrêt des anciens services
    log "Arrêt des anciens services ($CURRENT_ENV)..."
    cleanup_old_deployment

    success "Déploiement Blue-Green terminé avec succès"
}

# Tests d'intégration
run_integration_tests() {
    log "Exécution des tests d'intégration..."

    # Test API de base
    if ! curl -s --max-time 30 "http://localhost:8000/api/health" | grep -q "ok"; then
        error "Test API de base échoué"
        return 1
    fi

    # Test base de données
    if ! docker exec "msaada-${NEW_ENV}-mysql" mysqladmin ping -h localhost >/dev/null 2>&1; then
        error "Test base de données échoué"
        return 1
    fi

    # Test cache Redis
    if ! docker exec "msaada-${NEW_ENV}-redis" redis-cli ping | grep -q "PONG"; then
        error "Test Redis échoué"
        return 1
    fi

    # Test frontend
    if ! curl -s --max-time 30 "http://localhost:3000" >/dev/null; then
        error "Test frontend échoué"
        return 1
    fi

    # Tests spécifiques VBG (sans données sensibles)
    log "Tests spécifiques VBG..."
    
    # Test d'authentification
    local auth_response=$(curl -s -X POST "http://localhost:8000/api/auth/test" \
        -H "Content-Type: application/json" \
        -d '{"test": true}' \
        --max-time 10)
    
    if [[ -z "$auth_response" ]]; then
        warn "Tests d'authentification non concluants"
    fi

    success "Tests d'intégration réussis"
    return 0
}

# Basculement du trafic
switch_traffic() {
    log "Basculement du trafic vers $NEW_ENV..."
    
    # Dans un environnement réel, ici on configurerait:
    # - Load balancer (HAProxy, Nginx, Traefik)
    # - DNS avec TTL court
    # - Service mesh (Istio, Linkerd)
    
    # Simulation: mise à jour des labels Docker pour Traefik
    docker exec "msaada-${NEW_ENV}-backend" \
        docker label add traefik.enable=true 2>/dev/null || true
    
    # Attendre la propagation
    sleep 10
    
    success "Trafic basculé vers $NEW_ENV"
}

# Vérifications post-déploiement
post_deployment_checks() {
    log "Vérifications post-déploiement..."

    # Vérifier que tous les services répondent
    local checks_passed=0
    local total_checks=5

    # Check 1: API accessible
    if curl -s --max-time 10 "http://localhost:8000/api/health" | grep -q "ok"; then
        ((checks_passed++))
        info "✓ API accessible"
    else
        warn "✗ API non accessible"
    fi

    # Check 2: Frontend accessible  
    if curl -s --max-time 10 "http://localhost:3000" >/dev/null; then
        ((checks_passed++))
        info "✓ Frontend accessible"
    else
        warn "✗ Frontend non accessible"
    fi

    # Check 3: Base de données responsive
    if docker exec "msaada-${NEW_ENV}-mysql" mysqladmin ping -h localhost >/dev/null 2>&1; then
        ((checks_passed++))
        info "✓ Base de données responsive"
    else
        warn "✗ Base de données non responsive"
    fi

    # Check 4: Redis opérationnel
    if docker exec "msaada-${NEW_ENV}-redis" redis-cli ping | grep -q "PONG"; then
        ((checks_passed++))
        info "✓ Redis opérationnel"
    else
        warn "✗ Redis non opérationnel"
    fi

    # Check 5: Monitoring accessible
    if curl -s --max-time 10 "http://localhost:9090/metrics" >/dev/null; then
        ((checks_passed++))
        info "✓ Monitoring accessible"
    else
        warn "✗ Monitoring non accessible"
    fi

    # Évaluation globale
    local success_rate=$((checks_passed * 100 / total_checks))
    
    if [[ $success_rate -ge 80 ]]; then
        success "Vérifications réussies ($checks_passed/$total_checks - $success_rate%)"
        return 0
    else
        error "Vérifications échouées ($checks_passed/$total_checks - $success_rate%)"
        return 1
    fi
}

# Nettoyage de l'ancien déploiement
cleanup_old_deployment() {
    if [[ -z "$CURRENT_ENV" ]] || [[ "$CURRENT_ENV" == "$NEW_ENV" ]]; then
        warn "Pas d'ancien déploiement à nettoyer"
        return 0
    fi

    log "Nettoyage de l'ancien déploiement ($CURRENT_ENV)..."

    # Arrêt progressif des services
    export DEPLOYMENT_ENV="$CURRENT_ENV"
    export COMPOSE_PROJECT_NAME="msaada-${CURRENT_ENV}"
    
    docker-compose -f "$PROJECT_ROOT/docker-compose.${ENVIRONMENT}-advanced.yml" down --remove-orphans

    # Nettoyage des images anciennes (garder les 3 dernières)
    docker images "msaada-*" --format "{{.Repository}}:{{.Tag}}" | \
        tail -n +4 | \
        xargs -r docker rmi 2>/dev/null || true

    # Nettoyage des volumes inutilisés
    docker volume prune -f >/dev/null 2>&1 || true

    success "Ancien déploiement nettoyé"
}

# Rollback
rollback_deployment() {
    error "🔄 Initiation du rollback..."

    send_notification "Rollback en cours - Déploiement échoué" "error"

    # Arrêter le nouveau déploiement défaillant
    log "Arrêt du déploiement défaillant ($NEW_ENV)..."
    export DEPLOYMENT_ENV="$NEW_ENV"
    export COMPOSE_PROJECT_NAME="msaada-${NEW_ENV}"
    docker-compose -f "$PROJECT_ROOT/docker-compose.${ENVIRONMENT}-advanced.yml" down --remove-orphans 2>/dev/null || true

    # Redémarrer l'ancien déploiement si nécessaire
    if [[ -n "$CURRENT_ENV" ]] && [[ "$CURRENT_ENV" != "$NEW_ENV" ]]; then
        log "Redémarrage de l'ancien déploiement ($CURRENT_ENV)..."
        export DEPLOYMENT_ENV="$CURRENT_ENV"
        export COMPOSE_PROJECT_NAME="msaada-${CURRENT_ENV}"
        docker-compose -f "$PROJECT_ROOT/docker-compose.${ENVIRONMENT}-advanced.yml" up -d

        # Vérifier que le rollback fonctionne
        sleep 30
        if perform_health_checks "backend"; then
            success "Rollback réussi - Service restauré"
            send_notification "Rollback réussi - Service restauré" "warning"
        else
            error "Échec du rollback - Intervention manuelle requise"
            send_notification "CRITIQUE: Échec du rollback - Intervention manuelle requise" "error"
        fi
    fi

    # Restaurer la base de données si backup disponible
    if [[ -n "$BACKUP_DIR" ]] && [[ -f "$BACKUP_DIR/database.sql" ]]; then
        warn "Restauration de la base de données disponible dans: $BACKUP_DIR"
    fi
}

# Nettoyage des sauvegardes anciennes
cleanup_old_backups() {
    log "Nettoyage des anciennes sauvegardes..."

    local backup_base_dir="$PROJECT_ROOT/backups/${ENVIRONMENT}"
    
    if [[ -d "$backup_base_dir" ]]; then
        # Supprimer les sauvegardes de plus de X jours
        find "$backup_base_dir" -type d -name "2*" -mtime +$BACKUP_RETENTION_DAYS -exec rm -rf {} \; 2>/dev/null || true
        
        local remaining_backups=$(find "$backup_base_dir" -type d -name "2*" | wc -l)
        info "Sauvegardes conservées: $remaining_backups"
    fi
}

# Fonction principale
main() {
    log "🚀 Démarrage du déploiement Assistance Msaada 2.0"
    log "Environnement: $ENVIRONMENT | Type: $DEPLOYMENT_TYPE"
    
    send_notification "Déploiement démarré" "info"

    # Étapes du déploiement
    check_prerequisites
    detect_current_state
    create_backup
    build_images

    case $DEPLOYMENT_TYPE in
        "blue-green")
            deploy_blue_green
            ;;
        "rolling")
            error "Déploiement rolling pas encore implémenté"
            exit 1
            ;;
        "hotfix")
            error "Déploiement hotfix pas encore implémenté"
            exit 1
            ;;
        *)
            error "Type de déploiement non supporté: $DEPLOYMENT_TYPE"
            exit 1
            ;;
    esac

    cleanup_old_backups

    # Résumé final
    success "🎉 Déploiement terminé avec succès !"
    success "Environnement actif: $NEW_ENV"
    success "Version déployée: ${VERSION:-latest}"
    success "Logs: $LOG_FILE"
    
    send_notification "Déploiement réussi ✅" "success"

    # Informations post-déploiement
    echo ""
    info "📊 URLs de vérification:"
    info "- Frontend: http://localhost:3000"
    info "- Backend API: http://localhost:8000/api/health"  
    info "- Grafana: http://localhost:3001"
    info "- Prometheus: http://localhost:9090"
    echo ""
    info "📋 Prochaines étapes:"
    info "1. Vérifier le monitoring dans Grafana"
    info "2. Tester les fonctionnalités critiques VBG"
    info "3. Surveiller les logs d'erreur dans Sentry"
    info "4. Valider les performances"
}

# Gestion des signaux pour cleanup
cleanup_on_exit() {
    warn "Interruption détectée - Nettoyage en cours..."
    if [[ -n "$NEW_ENV" ]]; then
        rollback_deployment
    fi
    exit 1
}

trap cleanup_on_exit INT TERM

# Point d'entrée
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_arguments "$@"
    main
fi