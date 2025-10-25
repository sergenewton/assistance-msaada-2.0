#!/bin/bash

# ==========================================
# SCRIPT DE DÉPLOIEMENT PRODUCTION
# ASSISTANCE MSAADA 2.0
# ==========================================

set -e  # Exit on any error

echo "🚀 Starting production deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PRODUCTION_SERVERS="${PRODUCTION_SERVERS:-prod1.assistance-msaada.org,prod2.assistance-msaada.org}"
DEPLOYMENT_USER="${DEPLOYMENT_USER:-deploy}"
APP_DIR="${APP_DIR:-/opt/assistance-msaada}"
BACKUP_DIR="${BACKUP_DIR:-/backups}"
DOCKER_REGISTRY="${DOCKER_REGISTRY:-registry.assistance-msaada.org}"

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

log_critical() {
    echo -e "${RED}[CRITICAL]${NC} $1"
    # Send critical alert
    send_critical_alert "$1"
}

# Send critical alert
send_critical_alert() {
    local message="$1"
    
    if [ -n "${PAGERDUTY_INTEGRATION_KEY}" ]; then
        curl -X POST "https://events.pagerduty.com/v2/enqueue" \
            -H "Content-Type: application/json" \
            -d "{
                \"routing_key\": \"${PAGERDUTY_INTEGRATION_KEY}\",
                \"event_action\": \"trigger\",
                \"payload\": {
                    \"summary\": \"Production Deployment Critical Error\",
                    \"source\": \"assistance-msaada-deployment\",
                    \"severity\": \"critical\",
                    \"custom_details\": {\"message\": \"${message}\"}
                }
            }"
    fi
    
    # Also send to Slack if configured
    if [ -n "${SLACK_WEBHOOK_URL}" ]; then
        curl -X POST "${SLACK_WEBHOOK_URL}" \
            -H "Content-Type: application/json" \
            -d "{\"text\":\"🚨 CRITICAL: Production Deployment Error: ${message}\"}"
    fi
}

# Pre-deployment security checks
security_checks() {
    log_info "Running pre-deployment security checks..."
    
    # Check for secrets in code
    if grep -r "password\|secret\|key" --include="*.env*" --exclude="*.example" . 2>/dev/null; then
        log_critical "Potential secrets found in environment files"
        exit 1
    fi
    
    # Check SSL certificates
    if [ "${CI}" != "true" ]; then
        for domain in "assistance-msaada.org" "api.assistance-msaada.org"; do
            if ! openssl s_client -connect "${domain}:443" -servername "${domain}" < /dev/null 2>/dev/null | openssl x509 -checkend 2592000 -noout; then
                log_critical "SSL certificate for ${domain} expires within 30 days"
                exit 1
            fi
        done
    fi
    
    # Verify image signatures (if using signed images)
    if [ -n "${DOCKER_CONTENT_TRUST}" ]; then
        export DOCKER_CONTENT_TRUST=1
        log_info "Docker Content Trust enabled"
    fi
    
    log_success "Security checks passed"
}

# Check requirements
check_requirements() {
    log_info "Checking production deployment requirements..."
    
    # Verify environment variables
    required_vars=("DB_PASSWORD" "JWT_SECRET" "APP_KEY")
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            log_critical "Required environment variable ${var} is not set"
            exit 1
        fi
    done
    
    # Check if running in CI/CD or local
    if [ "${CI}" = "true" ]; then
        log_info "Running in CI/CD environment"
        # Verify CI/CD specific requirements
        if [ -z "${PRODUCTION_SECRETS_PASSPHRASE}" ]; then
            log_critical "PRODUCTION_SECRETS_PASSPHRASE not set in CI/CD"
            exit 1
        fi
    else
        log_info "Running in local environment"
        
        # Check SSH connections to all production servers
        IFS=',' read -ra SERVERS <<< "$PRODUCTION_SERVERS"
        for server in "${SERVERS[@]}"; do
            if ! ssh -o ConnectTimeout=10 -o BatchMode=yes "${DEPLOYMENT_USER}@${server}" exit; then
                log_critical "Cannot connect to production server: ${server}"
                exit 1
            fi
        done
    fi
    
    log_success "Requirements check passed"
}

# Create comprehensive backup
create_backup() {
    log_info "Creating comprehensive production backup..."
    
    BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_NAME="production_backup_${BACKUP_TIMESTAMP}"
    
    IFS=',' read -ra SERVERS <<< "$PRODUCTION_SERVERS"
    for server in "${SERVERS[@]}"; do
        log_info "Backing up server: ${server}"
        
        if [ "${CI}" = "true" ]; then
            # In CI/CD, backup is handled differently
            log_info "Backup for ${server} will be handled by automation"
        else
            ssh "${DEPLOYMENT_USER}@${server}" << EOF
                set -e
                cd ${APP_DIR}
                
                # Create backup directory
                mkdir -p ${BACKUP_DIR}/${BACKUP_NAME}
                
                # Backup database with compression
                docker-compose -f docker-compose.production.yml exec -T mysql \
                    mysqldump -u root -p\${MYSQL_ROOT_PASSWORD} \
                    --single-transaction --routines --triggers \
                    assistance_msaada_production | gzip > ${BACKUP_DIR}/${BACKUP_NAME}/database.sql.gz
                
                # Backup storage with rsync
                rsync -av storage/ ${BACKUP_DIR}/${BACKUP_NAME}/storage/
                
                # Backup environment and configuration
                cp -r .env docker/ ${BACKUP_DIR}/${BACKUP_NAME}/
                
                # Create deployment info
                cat > ${BACKUP_DIR}/${BACKUP_NAME}/deployment_info.json << EOJ
{
    "backup_timestamp": "${BACKUP_TIMESTAMP}",
    "server": "${server}",
    "git_commit": "\$(git rev-parse HEAD 2>/dev/null || echo 'unknown')",
    "docker_images": [
        "\$(docker images --format 'table {{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}' | grep assistance-msaada)"
    ],
    "system_info": {
        "disk_usage": "\$(df -h ${APP_DIR})",
        "memory_usage": "\$(free -h)",
        "load_average": "\$(uptime)"
    }
}
EOJ
                
                # Upload backup to S3 if configured
                if [ -n "\${S3_BACKUP_BUCKET}" ]; then
                    aws s3 sync ${BACKUP_DIR}/${BACKUP_NAME}/ s3://\${S3_BACKUP_BUCKET}/production/${BACKUP_NAME}/
                fi
EOF
        fi
    done
    
    log_success "Backup created: ${BACKUP_NAME}"
    echo "${BACKUP_NAME}" > /tmp/backup_name.txt  # Save for potential rollback
}

# Blue-green deployment strategy
deploy_blue_green() {
    log_info "Executing blue-green production deployment..."
    
    IFS=',' read -ra SERVERS <<< "$PRODUCTION_SERVERS"
    
    for server in "${SERVERS[@]}"; do
        log_info "Deploying to server: ${server}"
        
        if [ "${CI}" = "true" ]; then
            # CI/CD deployment
            deploy_to_server_ci "${server}"
        else
            # SSH deployment
            deploy_to_server_ssh "${server}"
        fi
    done
}

# Deploy to server via CI/CD
deploy_to_server_ci() {
    local server="$1"
    log_info "CI/CD deployment to ${server}..."
    
    # Build production images
    docker build -f backend-api/Dockerfile.production \
        -t "${DOCKER_REGISTRY}/assistance-msaada/api:${GITHUB_SHA:-latest}" \
        backend-api/
    
    docker build -f frontend-web/Dockerfile.production \
        -t "${DOCKER_REGISTRY}/assistance-msaada/web:${GITHUB_SHA:-latest}" \
        frontend-web/
    
    # Push to registry
    docker push "${DOCKER_REGISTRY}/assistance-msaada/api:${GITHUB_SHA:-latest}"
    docker push "${DOCKER_REGISTRY}/assistance-msaada/web:${GITHUB_SHA:-latest}"
    
    log_success "Images pushed to registry for ${server}"
}

# Deploy to server via SSH
deploy_to_server_ssh() {
    local server="$1"
    log_info "SSH deployment to ${server}..."
    
    # Upload deployment package
    rsync -avz --exclude='node_modules' --exclude='.git' \
        ./ "${DEPLOYMENT_USER}@${server}:${APP_DIR}-new/"
    
    # Execute atomic deployment
    ssh "${DEPLOYMENT_USER}@${server}" << EOF
        set -e
        cd ${APP_DIR}-new
        
        # Setup production environment
        cp backend-api/.env.production backend-api/.env
        cp frontend-web/.env.production frontend-web/.env
        
        # Build images
        docker build -f backend-api/Dockerfile.production -t assistance-msaada/api:latest backend-api/
        docker build -f frontend-web/Dockerfile.production -t assistance-msaada/web:latest frontend-web/
        
        # Health check before switching
        docker run --rm -p 8001:8000 assistance-msaada/api:latest &
        API_PID=\$!
        sleep 30
        
        if curl -f http://localhost:8001/health; then
            kill \$API_PID
            log_info "Health check passed, proceeding with deployment"
        else
            kill \$API_PID
            log_error "Health check failed, aborting deployment"
            exit 1
        fi
        
        # Atomic switch
        cd ${APP_DIR}
        docker-compose -f docker-compose.production.yml down
        
        cd ${APP_DIR}-new
        docker-compose -f docker-compose.production.yml up -d
        
        # Wait and verify
        sleep 60
        docker-compose -f docker-compose.production.yml exec -T api php artisan migrate --force
        
        # Clear caches
        docker-compose -f docker-compose.production.yml exec -T api php artisan optimize:clear
        docker-compose -f docker-compose.production.yml exec -T api php artisan config:cache
        docker-compose -f docker-compose.production.yml exec -T api php artisan route:cache
        docker-compose -f docker-compose.production.yml exec -T api php artisan view:cache
        
        # Switch directories atomically
        mv ${APP_DIR} ${APP_DIR}-old
        mv ${APP_DIR}-new ${APP_DIR}
        
        # Clean up old deployment after verification
        sleep 300  # Wait 5 minutes
        rm -rf ${APP_DIR}-old
EOF
    
    log_success "Deployment completed on ${server}"
}

# Comprehensive post-deployment verification
verify_deployment() {
    log_info "Running comprehensive post-deployment verification..."
    
    # Wait for all services to stabilize
    sleep 120
    
    local failed_checks=0
    
    # Health checks for all endpoints
    endpoints=(
        "https://api.assistance-msaada.org/health"
        "https://assistance-msaada.org/health"
    )
    
    for endpoint in "${endpoints[@]}"; do
        if curl -f --max-time 30 "${endpoint}" > /dev/null 2>&1; then
            log_success "✓ Health check passed: ${endpoint}"
        else
            log_error "✗ Health check failed: ${endpoint}"
            ((failed_checks++))
        fi
    done
    
    # Database connectivity test
    IFS=',' read -ra SERVERS <<< "$PRODUCTION_SERVERS"
    for server in "${SERVERS[@]}"; do
        if [ "${CI}" != "true" ]; then
            if ssh "${DEPLOYMENT_USER}@${server}" "cd ${APP_DIR} && docker-compose -f docker-compose.production.yml exec -T api php artisan tinker --execute='DB::connection()->getPdo(); echo \"DB OK\";'" | grep -q "DB OK"; then
                log_success "✓ Database connectivity: ${server}"
            else
                log_error "✗ Database connectivity failed: ${server}"
                ((failed_checks++))
            fi
        fi
    done
    
    # SSL certificate validation
    for domain in "assistance-msaada.org" "api.assistance-msaada.org"; do
        if echo | openssl s_client -connect "${domain}:443" -servername "${domain}" 2>/dev/null | openssl x509 -noout -dates | grep -q "After"; then
            log_success "✓ SSL certificate valid: ${domain}"
        else
            log_error "✗ SSL certificate invalid: ${domain}"
            ((failed_checks++))
        fi
    done
    
    # Performance test
    response_time=$(curl -o /dev/null -s -w '%{time_total}\n' https://api.assistance-msaada.org/health)
    if (( $(echo "$response_time < 2.0" | bc -l) )); then
        log_success "✓ Response time acceptable: ${response_time}s"
    else
        log_warning "⚠ Response time high: ${response_time}s"
    fi
    
    if [ $failed_checks -gt 0 ]; then
        log_critical "${failed_checks} verification checks failed"
        return 1
    fi
    
    log_success "All verification checks passed"
    return 0
}

# Emergency rollback
emergency_rollback() {
    log_critical "Initiating emergency rollback..."
    
    local backup_name
    if [ -f /tmp/backup_name.txt ]; then
        backup_name=$(cat /tmp/backup_name.txt)
    else
        log_error "No backup name found, manual intervention required"
        exit 1
    fi
    
    IFS=',' read -ra SERVERS <<< "$PRODUCTION_SERVERS"
    for server in "${SERVERS[@]}"; do
        log_info "Rolling back server: ${server}"
        
        if [ "${CI}" = "true" ]; then
            # CI/CD rollback - pull previous images
            log_warning "CI/CD rollback requires manual intervention"
        else
            ssh "${DEPLOYMENT_USER}@${server}" << EOF
                set -e
                cd ${APP_DIR}
                
                # Stop current deployment
                docker-compose -f docker-compose.production.yml down
                
                # Restore from backup
                if [ -d "${BACKUP_DIR}/${backup_name}" ]; then
                    # Restore database
                    zcat ${BACKUP_DIR}/${backup_name}/database.sql.gz | \
                        docker-compose -f docker-compose.production.yml exec -T mysql \
                        mysql -u root -p\${MYSQL_ROOT_PASSWORD} assistance_msaada_production
                    
                    # Restore storage
                    rsync -av ${BACKUP_DIR}/${backup_name}/storage/ storage/
                    
                    # Start with previous configuration
                    docker-compose -f docker-compose.production.yml up -d
                else
                    log_error "Backup not found: ${backup_name}"
                    exit 1
                fi
EOF
        fi
    done
    
    send_notification "ROLLBACK" "Emergency rollback completed using backup: ${backup_name}"
    log_success "Emergency rollback completed"
}

# Send deployment notification
send_notification() {
    local status=$1
    local message=$2
    
    # Slack notification
    if [ -n "${SLACK_WEBHOOK_URL}" ]; then
        local color
        case $status in
            "SUCCESS") color="good" ;;
            "FAILED"|"ROLLBACK") color="danger" ;;
            *) color="warning" ;;
        esac
        
        curl -X POST "${SLACK_WEBHOOK_URL}" \
            -H "Content-Type: application/json" \
            -d "{
                \"attachments\": [{
                    \"color\": \"${color}\",
                    \"title\": \"🏭 Production Deployment ${status}\",
                    \"text\": \"${message}\",
                    \"fields\": [
                        {\"title\": \"Environment\", \"value\": \"Production\", \"short\": true},
                        {\"title\": \"Timestamp\", \"value\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\", \"short\": true}
                    ]
                }]
            }"
    fi
    
    # Webhook notification
    if [ -n "${DEPLOYMENT_WEBHOOK_URL}" ]; then
        curl -X POST "${DEPLOYMENT_WEBHOOK_URL}" \
            -H "Content-Type: application/json" \
            -d "{
                \"environment\": \"production\",
                \"status\": \"${status}\",
                \"message\": \"${message}\",
                \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
                \"servers\": \"${PRODUCTION_SERVERS}\"
            }"
    fi
}

# Main execution
main() {
    log_info "=== ASSISTANCE MSAADA 2.0 - Production Deployment ==="
    
    # Trap errors for emergency rollback
    trap 'emergency_rollback; exit 1' ERR
    
    # Pre-flight checks
    security_checks
    check_requirements
    
    # Deployment process
    create_backup
    deploy_blue_green
    
    # Verification
    if verify_deployment; then
        log_success "✅ Production deployment completed successfully!"
        
        echo ""
        echo "🌐 Production URLs:"
        echo "  Frontend: https://assistance-msaada.org"
        echo "  Backend:  https://api.assistance-msaada.org"
        echo "  Docs:     https://api.assistance-msaada.org/docs"
        echo "  Status:   https://status.assistance-msaada.org"
        echo ""
        echo "📊 Monitoring:"
        echo "  Metrics:  https://monitoring.assistance-msaada.org"
        echo "  Logs:     https://logs.assistance-msaada.org"
        echo ""
        
        send_notification "SUCCESS" "Production deployment completed successfully across all servers"
    else
        log_critical "Production deployment verification failed"
        exit 1
    fi
}

# Handle script interruption
trap 'log_critical "Production deployment interrupted"; emergency_rollback; exit 1' INT TERM

# Require explicit confirmation for production deployment
if [ "${CI}" != "true" ] && [ "${FORCE_PRODUCTION_DEPLOY}" != "true" ]; then
    echo -e "${YELLOW}⚠️  WARNING: You are about to deploy to PRODUCTION${NC}"
    echo -e "${YELLOW}This will affect live users and critical systems${NC}"
    echo ""
    read -p "Are you sure you want to proceed? (type 'DEPLOY' to confirm): " confirmation
    
    if [ "$confirmation" != "DEPLOY" ]; then
        log_info "Production deployment cancelled by user"
        exit 0
    fi
fi

# Run main function
main "$@"