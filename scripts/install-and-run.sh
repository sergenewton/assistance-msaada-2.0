#!/bin/bash
# Unified installer/runner for backend, frontend, and MySQL DB
# Usage examples:
#   Docker only (fails if Docker not available):
#     ./scripts/install-and-run.sh --db-docker
#   Local only (fails if local MySQL not available):
#     ./scripts/install-and-run.sh --db-local
#   Variants:
#     ./scripts/install-and-run.sh --db-docker --status
#     ./scripts/install-and-run.sh --db-local --backend-only
#     ./scripts/install-and-run.sh --db-local --frontend-only
#     ./scripts/install-and-run.sh --db-docker --db-only
#     ./scripts/install-and-run.sh --stop

set -euo pipefail

# --- Paths & constants ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKEND_DIR="$ROOT_DIR/backend-api"
FRONTEND_DIR="$ROOT_DIR/frontend-web"
COMPOSE_MYSQL="$ROOT_DIR/docker-compose.mysql.yml"
LOG_DIR="$ROOT_DIR/logs"
STATE_DIR="$ROOT_DIR/.run"
BACKEND_LOG="$LOG_DIR/install-and-run-backend.log"
FRONTEND_LOG="$LOG_DIR/install-and-run-frontend.log"
BACKEND_PID="$STATE_DIR/backend.pid"
FRONTEND_PID="$STATE_DIR/frontend.pid"
MODE_FILE="$STATE_DIR/mode"
DB_ONLY_FLAG=false
BACKEND_ONLY_FLAG=false
FRONTEND_ONLY_FLAG=false
STATUS_FLAG=false
STOP_FLAG=false
DB_MODE="" # docker|local

# Ensure dirs
mkdir -p "$LOG_DIR" "$STATE_DIR"

# --- Helpers ---
info() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*" >&2; }
err()  { echo "[ERROR] $*" >&2; }

is_port_open() {
  local host="$1"; local port="$2";
  nc -z "$host" "$port" >/dev/null 2>&1
}

wait_for_port() {
  local host="$1"; local port="$2"; local label="$3"; local attempts="${4:-60}"; local sleep_s="${5:-1}";
  for i in $(seq 1 "$attempts"); do
    if is_port_open "$host" "$port"; then
      info "$label is reachable on $host:$port"
      return 0
    fi
    sleep "$sleep_s"
  done
  err "$label did not become ready on $host:$port in time"
  return 1
}

pid_is_running() {
  local pid_file="$1"
  [[ -f "$pid_file" ]] || return 1
  local pid
  pid=$(cat "$pid_file" 2>/dev/null || true)
  [[ -n "${pid:-}" ]] || return 1
  if kill -0 "$pid" >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

kill_pidfile() {
  local pid_file="$1"; local name="$2"
  if pid_is_running "$pid_file"; then
    local pid
    pid=$(cat "$pid_file")
    info "Stopping $name (pid=$pid)"
    kill "$pid" >/dev/null 2>&1 || true
    # Graceful wait then force
    for i in {1..10}; do
      if kill -0 "$pid" >/dev/null 2>&1; then sleep 0.3; else break; fi
    done
    if kill -0 "$pid" >/dev/null 2>&1; then
      warn "$name did not exit, forcing..."
      kill -9 "$pid" >/dev/null 2>&1 || true
    fi
  fi
  rm -f "$pid_file"
}

ensure_backend_env() {
  cd "$BACKEND_DIR"
  if [[ ! -f .env ]]; then
    info "Creating backend .env from .env.example"
    cp .env.example .env
  fi
  # macOS/BSD sed in-place
  sed -i '' "s/^DB_HOST=.*/DB_HOST=$1/" .env || true
  sed -i '' "s/^DB_PORT=.*/DB_PORT=$2/" .env || true
  sed -i '' "s/^DB_DATABASE=.*/DB_DATABASE=vbg_platform/" .env || true
  sed -i '' "s/^DB_USERNAME=.*/DB_USERNAME=vbg/" .env || true
  sed -i '' "s/^DB_PASSWORD=.*/DB_PASSWORD=vbgpass/" .env || true
  if grep -q '^SESSION_DRIVER=' .env; then
    sed -i '' "s/^SESSION_DRIVER=.*/SESSION_DRIVER=array/" .env || true
  else
    echo "SESSION_DRIVER=array" >> .env
  fi
}

install_backend() {
  cd "$BACKEND_DIR"
  if ! command -v composer >/dev/null 2>&1; then
    err "Composer is required for backend install. Please install Composer."
    exit 1
  fi
  info "Installing backend dependencies (composer install)"
  composer install --no-interaction --prefer-dist >>"$BACKEND_LOG" 2>&1
  info "Generating keys and running migrations/seeds"
  php artisan key:generate --no-interaction >>"$BACKEND_LOG" 2>&1 || true
  php artisan jwt:secret --force >>"$BACKEND_LOG" 2>&1 || true
  php artisan migrate --no-interaction --force >>"$BACKEND_LOG" 2>&1
  php artisan db:seed --class=InitialSetupSeeder --no-interaction --force >>"$BACKEND_LOG" 2>&1 || true
}

start_backend() {
  cd "$BACKEND_DIR"
  if pid_is_running "$BACKEND_PID"; then
    info "Backend already running (pid $(cat "$BACKEND_PID"))"
    return 0
  fi
  info "Starting backend (Laravel artisan serve on :8000)"
  nohup php artisan serve --host=127.0.0.1 --port=8000 >>"$BACKEND_LOG" 2>&1 &
  echo $! > "$BACKEND_PID"
  sleep 1
  wait_for_port 127.0.0.1 8000 "Backend" 30 1
}

install_frontend() {
  cd "$FRONTEND_DIR"
  if ! command -v npm >/dev/null 2>&1; then
    err "Node.js/npm is required for frontend install. Please install Node.js."
    exit 1
  fi
  info "Installing frontend dependencies (npm install)"
  npm install >>"$FRONTEND_LOG" 2>&1
}

start_frontend() {
  cd "$FRONTEND_DIR"
  if pid_is_running "$FRONTEND_PID"; then
    info "Frontend already running (pid $(cat "$FRONTEND_PID"))"
    return 0
  fi
  info "Starting frontend (Vite dev server on :3000)"
  nohup npm run dev >>"$FRONTEND_LOG" 2>&1 &
  echo $! > "$FRONTEND_PID"
  # Vite sometimes needs a few seconds to boot
  wait_for_port 127.0.0.1 3000 "Frontend" 60 1 || warn "Frontend port 3000 not ready yet; it may still be warming up."
}

start_db_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    err "Docker is required but not installed."
    exit 1
  fi
  if ! docker ps >/dev/null 2>&1; then
    err "Docker daemon not available. Start Docker Desktop first."
    exit 1
  fi
  info "Starting MySQL via Docker compose (host port 3307)"
  docker compose -f "$COMPOSE_MYSQL" up -d --wait
  wait_for_port 127.0.0.1 3307 "MySQL (Docker)" 60 1
}

status_db_docker() {
  if is_port_open 127.0.0.1 3307; then echo "DB(Docker): UP on 3307"; else echo "DB(Docker): DOWN"; fi
}

status_db_local() {
  if is_port_open 127.0.0.1 3306; then echo "DB(Local): UP on 3306"; else echo "DB(Local): DOWN"; fi
}

stop_db_docker() {
  if [[ -f "$COMPOSE_MYSQL" ]]; then
    info "Stopping Docker MySQL stack"
    docker compose -f "$COMPOSE_MYSQL" down >/dev/null 2>&1 || true
  fi
}

status_all() {
  # DB
  if [[ "$DB_MODE" == "docker" ]]; then status_db_docker; else status_db_local; fi
  # Backend
  if pid_is_running "$BACKEND_PID"; then echo "Backend: RUNNING (pid $(cat "$BACKEND_PID"))"; else echo "Backend: STOPPED"; fi
  code=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8000/api/health || true)
  [[ "$code" == "200" ]] && echo "Backend health: OK" || echo "Backend health: $code"
  # Frontend
  if pid_is_running "$FRONTEND_PID"; then echo "Frontend: RUNNING (pid $(cat "$FRONTEND_PID"))"; else echo "Frontend: STOPPED"; fi
  if is_port_open 127.0.0.1 3000; then echo "Frontend port 3000: OPEN"; else echo "Frontend port 3000: CLOSED"; fi
}

stop_all() {
  kill_pidfile "$BACKEND_PID" "backend"
  kill_pidfile "$FRONTEND_PID" "frontend"
  # Stop docker DB if last mode was docker
  if [[ -f "$MODE_FILE" ]] && [[ "$(cat "$MODE_FILE")" == "docker" ]]; then
    stop_db_docker
  fi
}

# --- Parse args ---
if [[ $# -eq 0 ]]; then
  err "You must pass --db-docker or --db-local. See --help in the header."
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --db-docker) DB_MODE="docker"; shift ;;
    --db-local)  DB_MODE="local"; shift ;;
    --db-only) DB_ONLY_FLAG=true; shift ;;
    --backend-only) BACKEND_ONLY_FLAG=true; shift ;;
    --frontend-only) FRONTEND_ONLY_FLAG=true; shift ;;
    --status) STATUS_FLAG=true; shift ;;
    --stop) STOP_FLAG=true; shift ;;
    *) err "Unknown argument: $1"; exit 1 ;;
  esac
done

if [[ -z "$DB_MODE" ]]; then
  err "You must choose exactly one: --db-docker or --db-local"
  exit 1
fi

# Persist chosen mode for stop
echo "$DB_MODE" > "$MODE_FILE"

# --- Execute requested actions ---
if [[ "$STOP_FLAG" == true ]]; then
  stop_all
  exit 0
fi

if [[ "$STATUS_FLAG" == true ]]; then
  status_all
  exit 0
fi

# DB setup by mode (no fallback)
if [[ "$DB_MODE" == "docker" ]]; then
  start_db_docker
  DB_HOST=127.0.0.1
  DB_PORT=3307
else
  # local
  if ! command -v mysql >/dev/null 2>&1 && ! command -v mariadb >/dev/null 2>&1; then
    err "MySQL client is not installed locally. Please install MySQL."
    exit 1
  fi
  if ! is_port_open 127.0.0.1 3306; then
    err "Local MySQL is not reachable on 127.0.0.1:3306"
    exit 1
  fi
  DB_HOST=127.0.0.1
  DB_PORT=3306
fi

# Only DB requested
if [[ "$DB_ONLY_FLAG" == true ]]; then
  info "DB-only mode selected; exiting after DB setup."
  exit 0
fi

# Backend
ensure_backend_env "$DB_HOST" "$DB_PORT"
install_backend
if [[ "$FRONTEND_ONLY_FLAG" != true ]]; then
  start_backend
fi

# Frontend
install_frontend
if [[ "$BACKEND_ONLY_FLAG" != true ]]; then
  start_frontend
fi

info "All set. Logs:"
info "  Backend log:   $BACKEND_LOG"
info "  Frontend log:  $FRONTEND_LOG"
info "Status summary:"
status_all
