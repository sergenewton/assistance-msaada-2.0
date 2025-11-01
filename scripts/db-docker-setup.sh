#!/bin/bash
# Start MySQL in Docker (host port 3307), configure Laravel .env, run migrations & seeds
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKEND_DIR="$ROOT_DIR/backend-api"

USE_DOCKER=true
if ! docker ps >/dev/null 2>&1; then
  echo "⚠️  Docker n'est pas disponible. Bascule en mode MySQL local (3306)."
  USE_DOCKER=false
fi

if [[ "$USE_DOCKER" == "true" ]]; then
  echo "🚀 Starting MySQL (Docker) on host port 3307..."
  docker compose -f "$ROOT_DIR/docker-compose.mysql.yml" up -d --wait

  echo "⏳ Waiting for MySQL to be reachable on 127.0.0.1:3307..."
  for i in {1..60}; do
    if nc -z 127.0.0.1 3307 >/dev/null 2>&1; then
      echo "✅ MySQL is reachable on 127.0.0.1:3307"
      break
    fi
    sleep 1
    if [[ $i -eq 60 ]]; then
      echo "❌ MySQL did not become ready in time"; exit 1
    fi
  done
fi

cd "$BACKEND_DIR"

if [[ ! -f .env ]]; then
  echo "📝 Creating .env from .env.example"
  cp .env.example .env
fi

if [[ "$USE_DOCKER" == "true" ]]; then
  echo "🔧 Configuring .env for Docker MySQL (3307)"
  sed -i '' "s/^DB_HOST=.*/DB_HOST=127.0.0.1/" .env || true
  sed -i '' "s/^DB_PORT=.*/DB_PORT=3307/" .env || true
else
  echo "🔧 Configuring .env for Local MySQL (3306)"
  sed -i '' "s/^DB_HOST=.*/DB_HOST=127.0.0.1/" .env || true
  sed -i '' "s/^DB_PORT=.*/DB_PORT=3306/" .env || true
fi
sed -i '' "s/^DB_DATABASE=.*/DB_DATABASE=vbg_platform/" .env || true
sed -i '' "s/^DB_USERNAME=.*/DB_USERNAME=vbg/" .env || true
sed -i '' "s/^DB_PASSWORD=.*/DB_PASSWORD=vbgpass/" .env || true

php artisan key:generate --no-interaction || true
php artisan jwt:secret --force >/dev/null 2>&1 || true

echo "📦 Running migrations and initial seeders..."
php artisan migrate --no-interaction --force
php artisan db:seed --class=InitialSetupSeeder --no-interaction --force || true

PORT_MSG="3306"
MODE_MSG="Local MySQL"
if [[ "$USE_DOCKER" == "true" ]]; then
  PORT_MSG="3307"
  MODE_MSG="Docker MySQL"
fi

# Ensure session driver is set to array for API-only local dev to avoid session driver errors
if grep -q '^SESSION_DRIVER=' .env; then
  sed -i '' "s/^SESSION_DRIVER=.*/SESSION_DRIVER=array/" .env || true
else
  echo "SESSION_DRIVER=array" >> .env
fi

echo "🎉 Database is ready (${MODE_MSG} on port ${PORT_MSG}). You can now run: ./quick-start-local.sh --backend-only"
