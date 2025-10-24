#!/bin/bash

# Script de démarrage pour la plateforme VBG
# Usage: ./dev-start.sh [backend|frontend|mobile|all]

set -e

BACKEND_DIR="backend-api"
FRONTEND_DIR="frontend-web"
MOBILE_DIR="mobile-app"

start_backend() {
    echo "🚀 Démarrage du Backend Laravel..."
    if [ -d "$BACKEND_DIR" ]; then
        cd "$BACKEND_DIR"
        if [ ! -f ".env" ]; then
            echo "📋 Copie du fichier .env..."
            cp .env.example .env
        fi
        
        echo "📦 Installation des dépendances..."
        composer install --quiet
        
        echo "🔑 Génération des clés..."
        php artisan key:generate --force
        
        if ! grep -q "JWT_SECRET" .env; then
            echo "🔐 Génération du secret JWT..."
            php artisan jwt:secret --force
        fi
        
        echo "🗄️ Exécution des migrations..."
        php artisan migrate --force
        
        echo "🌐 Démarrage du serveur Laravel sur le port 8000..."
        php artisan serve --port=8000 &
        BACKEND_PID=$!
        echo "✅ Backend démarré (PID: $BACKEND_PID)"
        cd ..
    else
        echo "❌ Dossier $BACKEND_DIR non trouvé"
    fi
}

start_frontend() {
    echo "🚀 Démarrage du Frontend React..."
    if [ -d "$FRONTEND_DIR" ]; then
        cd "$FRONTEND_DIR"
        
        echo "📦 Installation des dépendances..."
        npm install --silent
        
        echo "🌐 Démarrage du serveur de développement sur le port 3000..."
        npm run dev &
        FRONTEND_PID=$!
        echo "✅ Frontend démarré (PID: $FRONTEND_PID)"
        cd ..
    else
        echo "❌ Dossier $FRONTEND_DIR non trouvé"
    fi
}

start_mobile() {
    echo "🚀 Préparation de l'app Mobile Flutter..."
    if [ -d "$MOBILE_DIR" ]; then
        cd "$MOBILE_DIR"
        
        echo "📦 Installation des dépendances Flutter..."
        flutter pub get
        
        echo "🔨 Génération du code..."
        flutter pub run build_runner build --delete-conflicting-outputs
        
        echo "✅ App Mobile prête (utilisez 'flutter run' pour lancer)"
        cd ..
    else
        echo "❌ Dossier $MOBILE_DIR non trouvé"
    fi
}

cleanup() {
    echo -e "\n🛑 Arrêt des services..."
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null || true
        echo "✅ Backend arrêté"
    fi
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null || true
        echo "✅ Frontend arrêté"
    fi
    exit 0
}

trap cleanup SIGINT SIGTERM

case "${1:-all}" in
    "backend")
        start_backend
        ;;
    "frontend")
        start_frontend
        ;;
    "mobile")
        start_mobile
        ;;
    "all"|*)
        start_backend
        sleep 2
        start_frontend
        sleep 1
        start_mobile
        
        echo -e "\n🎉 Plateforme VBG démarrée avec succès!"
        echo "📍 Backend API: http://localhost:8000"
        echo "📍 Frontend Web: http://localhost:3000"
        echo "📍 Mobile: Utilisez 'flutter run' dans le dossier mobile-app"
        echo -e "\n⚠️  Appuyez sur Ctrl+C pour arrêter les services"
        
        # Attendre que l'utilisateur arrête
        wait
        ;;
esac