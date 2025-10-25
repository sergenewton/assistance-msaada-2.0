#!/bin/bash

# ==========================================
# SCRIPT DE DÉPLOIEMENT STAGING
# ASSISTANCE MSAADA 2.0
# ==========================================

set -e  # Exit on any error

echo "🚀 Starting staging deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
STAGING_SERVER="${STAGING_SERVER:-staging.assistance-msaada.org}"
DEPLOYMENT_USER="${DEPLOYMENT_USER:-deploy}"
APP_DIR="${APP_DIR:-/opt/assistance-msaada}"
BACKUP_DIR="${BACKUP_DIR:-/backups}"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check requirements
check_requirements() {
    log_info "Checking deployment requirements..."
    
    # Check if running in CI/CD or local
    if [ "${CI}" = "true" ]; then
        log_info "Running in CI/CD environment"
    else
        log_info "Running in local environment"
        
        # Check SSH connection
        if ! ssh -o ConnectTimeout=5 -o BatchMode=yes "${DEPLOYMENT_USER}@${STAGING_SERVER}" exit; then
            log_error "Cannot connect to staging server: ${STAGING_SERVER}"
            log_error "Please ensure SSH key is configured and server is accessible"
            exit 1
        fi
    fi
    
    log_success "Requirements check passed"
}

# Backup current deployment
backup_current_deployment() {
    log_info "Creating backup of current deployment..."
    
    BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_NAME="staging_backup_${BACKUP_TIMESTAMP}"
    
    if [ "${CI}" = "true" ]; then
        # In CI/CD, backup is handled by the workflow
        log_info "Backup will be handled by CI/CD workflow"
    else
        # Local deployment - backup via SSH
        ssh "${DEPLOYMENT_USER}@${STAGING_SERVER}" << EOF
            set -e
            cd ${APP_DIR}
            
            # Create backup directory
            mkdir -p ${BACKUP_DIR}/${BACKUP_NAME}
            
            # Backup database
            docker-compose -f docker-compose.staging.yml exec -T mysql \
                mysqladump -u root -p\${MYSQL_ROOT_PASSWORD} assistance_msaada_staging \
                > ${BACKUP_DIR}/${BACKUP_NAME}/database.sql
            
            # Backup storage
            cp -r storage ${BACKUP_DIR}/${BACKUP_NAME}/
            
            # Backup environment files
            cp .env ${BACKUP_DIR}/${BACKUP_NAME}/
            
            # Create deployment info
            echo "Backup created: \$(date)" > ${BACKUP_DIR}/${BACKUP_NAME}/info.txt
            echo "Git commit: \$(git rev-parse HEAD)" >> ${BACKUP_DIR}/${BACKUP_NAME}/info.txt
EOF
    fi
    
    log_success "Backup created: ${BACKUP_NAME}"
}

# Deploy to staging
deploy_to_staging() {
    log_info "Deploying to staging environment..."
    
    if [ "${CI}" = "true" ]; then
        # CI/CD deployment
        deploy_via_ci
    else
        # Local deployment
        deploy_via_ssh
    fi
}

# Deploy via CI/CD
deploy_via_ci() {
    log_info "Executing CI/CD staging deployment..."
    
    # Copy environment files
    cp backend-api/.env.staging backend-api/.env
    cp frontend-web/.env.staging frontend-web/.env
    
    # Build Docker images
    docker build -f backend-api/Dockerfile.staging -t assistance-msaada/api:staging backend-api/
    docker build -f frontend-web/Dockerfile.staging -t assistance-msaada/web:staging frontend-web/
    
    # Deploy using docker-compose
    docker-compose -f docker-compose.staging.yml down || true
    docker-compose -f docker-compose.staging.yml up -d --build
    
    log_success "CI/CD staging deployment completed"
}

# Deploy via SSH
deploy_via_ssh() {
    log_info "Executing SSH staging deployment..."
    
    # Upload files to staging server
    rsync -avz --exclude='node_modules' --exclude='.git' \
        ./ "${DEPLOYMENT_USER}@${STAGING_SERVER}:${APP_DIR}/"
    
    # Execute deployment on staging server
    ssh "${DEPLOYMENT_USER}@${STAGING_SERVER}" << EOF
        set -e
        cd ${APP_DIR}
        
        # Copy staging environment files
        cp backend-api/.env.staging backend-api/.env
        cp frontend-web/.env.staging frontend-web/.env
        
        # Pull latest images or build if needed
        docker-compose -f docker-compose.staging.yml pull || \
        docker-compose -f docker-compose.staging.yml build
        
        # Rolling deployment
        docker-compose -f docker-compose.staging.yml up -d --no-deps api web queue
        
        # Wait for services to be ready
        sleep 30
        
        # Run migrations
        docker-compose -f docker-compose.staging.yml exec -T api php artisan migrate --force
        
        # Clear caches
        docker-compose -f docker-compose.staging.yml exec -T api php artisan config:cache
        docker-compose -f docker-compose.staging.yml exec -T api php artisan route:cache
        docker-compose -f docker-compose.staging.yml exec -T api php artisan view:cache
        
        # Restart queue workers to pick up new code
        docker-compose -f docker-compose.staging.yml restart queue
EOF
    
    log_success "SSH staging deployment completed"
}

# Run post-deployment tests
run_post_deployment_tests() {
    log_info "Running post-deployment tests..."
    
    # Wait for services to stabilize
    sleep 30
    
    # Health checks
    STAGING_API_URL="https://staging-api.assistance-msaada.org"
    STAGING_WEB_URL="https://staging.assistance-msaada.org"
    
    # API health check
    if curl -f "${STAGING_API_URL}/health" > /dev/null 2>&1; then
        log_success "API health check passed"
    else
        log_error "API health check failed"
        return 1
    fi
    
    # Web health check
    if curl -f "${STAGING_WEB_URL}/health" > /dev/null 2>&1; then
        log_success "Web health check passed"
    else
        log_error "Web health check failed"
        return 1
    fi
    
    # Database connectivity test
    if [ "${CI}" != "true" ]; then
        ssh "${DEPLOYMENT_USER}@${STAGING_SERVER}" << 'EOF'
            cd /opt/assistance-msaada
            docker-compose -f docker-compose.staging.yml exec -T api php artisan tinker --execute="echo 'Database connection: ' . (DB::connection()->getPdo() ? 'OK' : 'FAILED');"
EOF
    fi
    
    log_success "Post-deployment tests completed"
}

# Send deployment notification
send_notification() {
    local status=$1
    local message=$2
    
    if [ -n "${SLACK_WEBHOOK_URL}" ]; then
        curl -X POST "${SLACK_WEBHOOK_URL}" \
            -H "Content-Type: application/json" \
            -d "{\"text\":\"🏗️ Staging Deployment ${status}: ${message}\"}"
    fi
    
    if [ -n "${DEPLOYMENT_WEBHOOK_URL}" ]; then
        curl -X POST "${DEPLOYMENT_WEBHOOK_URL}" \
            -H "Content-Type: application/json" \
            -d "{\"environment\":\"staging\",\"status\":\"${status}\",\"message\":\"${message}\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}"
    fi
}

# Rollback deployment
rollback_deployment() {
    log_error "Deployment failed, initiating rollback..."
    
    if [ "${CI}" = "true" ]; then
        # CI/CD rollback
        docker-compose -f docker-compose.staging.yml down
        # Here you would restore from backup or previous image
        log_warning "Manual rollback required in CI/CD environment"
    else
        # SSH rollback
        ssh "${DEPLOYMENT_USER}@${STAGING_SERVER}" << EOF
            set -e
            cd ${APP_DIR}
            
            # Stop current containers
            docker-compose -f docker-compose.staging.yml down
            
            # Restore previous deployment (implement based on your backup strategy)
            # This is a placeholder - implement actual rollback logic
            log_warning "Rollback initiated - manual intervention may be required"
            
            # Restart with previous configuration
            docker-compose -f docker-compose.staging.yml up -d
EOF
    fi
    
    send_notification "FAILED" "Deployment rolled back due to failure"
}

# Main execution
main() {
    log_info "=== ASSISTANCE MSAADA 2.0 - Staging Deployment ==="
    
    # Trap errors for rollback
    trap 'rollback_deployment; exit 1' ERR
    
    check_requirements
    backup_current_deployment
    deploy_to_staging
    
    # Run tests and handle failures
    if run_post_deployment_tests; then
        log_success "✅ Staging deployment completed successfully!"
        
        echo ""
        echo "🌐 Staging URLs:"
        echo "  Frontend: https://staging.assistance-msaada.org"
        echo "  Backend:  https://staging-api.assistance-msaada.org"
        echo "  Docs:     https://staging-api.assistance-msaada.org/docs"
        echo ""
        
        send_notification "SUCCESS" "Deployment completed successfully"
    else
        log_error "Post-deployment tests failed"
        exit 1
    fi
}

# Handle script interruption
trap 'log_error "Deployment interrupted"; exit 1' INT TERM

# Run main function
main "$@"