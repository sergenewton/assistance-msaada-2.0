#!/bin/bash

# ==========================================
# SCRIPT DE DÉPLOIEMENT DEVELOPMENT
# ASSISTANCE MSAADA 2.0
# ==========================================

set -e  # Exit on any error

echo "🚀 Starting development environment setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    log_info "Checking requirements..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    log_success "All requirements satisfied"
}

# Setup environment files
setup_environment() {
    log_info "Setting up environment files..."
    
    # Backend environment
    if [ ! -f "backend-api/.env" ]; then
        cp backend-api/.env.development backend-api/.env
        log_info "Created backend .env file from development template"
    else
        log_warning "Backend .env file already exists, skipping..."
    fi
    
    # Frontend environment  
    if [ ! -f "frontend-web/.env" ]; then
        cp frontend-web/.env.development frontend-web/.env
        log_info "Created frontend .env file from development template"
    else
        log_warning "Frontend .env file already exists, skipping..."
    fi
    
    log_success "Environment files configured"
}

# Create necessary directories
create_directories() {
    log_info "Creating necessary directories..."
    
    mkdir -p storage/app/public
    mkdir -p storage/logs
    mkdir -p backups/mysql
    mkdir -p docker/nginx
    mkdir -p docker/php
    mkdir -p docker/redis
    
    log_success "Directories created"
}

# Generate application keys
generate_keys() {
    log_info "Generating application keys..."
    
    if [ ! -f "backend-api/.env" ]; then
        log_error "Backend .env file not found"
        exit 1
    fi
    
    # Check if APP_KEY is already set
    if grep -q "APP_KEY=base64:" backend-api/.env; then
        log_warning "APP_KEY already set, skipping generation..."
    else
        # Generate APP_KEY using Laravel
        cd backend-api
        php artisan key:generate --force
        cd ..
        log_success "Laravel APP_KEY generated"
    fi
    
    # Generate JWT secret
    if grep -q "JWT_SECRET=.*" backend-api/.env && [ "$(grep JWT_SECRET backend-api/.env | cut -d'=' -f2)" != "" ]; then
        log_warning "JWT_SECRET already set, skipping generation..."
    else
        cd backend-api
        php artisan jwt:secret --force
        cd ..
        log_success "JWT secret generated"
    fi
}

# Start development environment
start_environment() {
    log_info "Starting development environment..."
    
    # Stop any existing containers
    docker-compose -f docker-compose.development.yml down
    
    # Build and start containers
    docker-compose -f docker-compose.development.yml up -d --build
    
    log_info "Waiting for services to start..."
    sleep 30
    
    # Check if MySQL is ready
    until docker-compose -f docker-compose.development.yml exec mysql mysqladmin ping -h"localhost" --silent; do
        log_info "Waiting for MySQL to be ready..."
        sleep 5
    done
    
    log_success "MySQL is ready"
}

# Setup database
setup_database() {
    log_info "Setting up database..."
    
    # Run migrations
    docker-compose -f docker-compose.development.yml exec api php artisan migrate --force
    
    # Seed database
    docker-compose -f docker-compose.development.yml exec api php artisan db:seed --force
    
    log_success "Database setup completed"
}

# Install dependencies
install_dependencies() {
    log_info "Installing dependencies..."
    
    # Backend dependencies
    docker-compose -f docker-compose.development.yml exec api composer install
    
    # Frontend dependencies
    docker-compose -f docker-compose.development.yml exec web npm install
    
    log_success "Dependencies installed"
}

# Display status
show_status() {
    log_success "Development environment is ready!"
    echo ""
    echo "📱 Services available:"
    echo "  🌐 Frontend Web:     http://localhost:5173"
    echo "  ⚙️  Backend API:      http://localhost:8000"
    echo "  📊 API Docs:         http://localhost:8000/docs"
    echo "  📧 MailHog:          http://localhost:8025"
    echo "  💾 MinIO Console:    http://localhost:9001"
    echo "  📈 Redis:            localhost:6379"
    echo "  🗄️  MySQL:           localhost:3306"
    echo ""
    echo "🛠️  Useful commands:"
    echo "  📊 View logs:        docker-compose -f docker-compose.development.yml logs -f"
    echo "  🔄 Restart:          docker-compose -f docker-compose.development.yml restart"
    echo "  🛑 Stop:             docker-compose -f docker-compose.development.yml down"
    echo "  🐚 Shell (API):      docker-compose -f docker-compose.development.yml exec api bash"
    echo "  🐚 Shell (Web):      docker-compose -f docker-compose.development.yml exec web sh"
    echo ""
    echo "📝 Default credentials:"
    echo "  MySQL: msaada_user / msaada_password"
    echo "  MinIO: minio / minio123"
    echo ""
}

# Main execution
main() {
    log_info "=== ASSISTANCE MSAADA 2.0 - Development Setup ==="
    
    check_requirements
    setup_environment
    create_directories
    
    # Only generate keys if not in CI/CD
    if [ "${CI}" != "true" ]; then
        generate_keys
    fi
    
    start_environment
    install_dependencies
    setup_database
    show_status
    
    log_success "✅ Development environment setup completed!"
}

# Handle script interruption
trap 'log_error "Script interrupted"; exit 1' INT TERM

# Run main function
main "$@"