#!/bin/bash
# DEPRECATED wrapper: please use scripts/install-and-run.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEW_SCRIPT="$ROOT_DIR/scripts/install-and-run.sh"

echo "[DEPRECATION] quick-start-local.sh est remplacé par scripts/install-and-run.sh"
echo "Utilisation recommandée:"
echo "  - Docker uniquement:   ./scripts/install-and-run.sh --db-docker"
echo "  - MySQL local uniquement: ./scripts/install-and-run.sh --db-local"
echo "  Variantes: --status | --backend-only | --frontend-only | --db-only | --stop"

if [[ ! -x "$NEW_SCRIPT" ]]; then
  echo "[ERROR] Script manquant: $NEW_SCRIPT" >&2
  exit 1
fi

# Map basic flags to forward
FORWARD_FLAGS=()
for arg in "$@"; do
  case "$arg" in
    --backend-only|--frontend-only|--db-only|--status|--stop)
      FORWARD_FLAGS+=("$arg")
      ;;
    --no-db)
      echo "[WARN] --no-db n'est plus supporté. La base sera gérée par le nouveau script selon le mode." >&2
      ;;
    *)
      # ignore unknown legacy flags
      ;;
  esac
done

# Auto-select DB mode for backward compatibility
DB_MODE=""
if command -v docker >/dev/null 2>&1 && docker ps >/dev/null 2>&1; then
  DB_MODE="--db-docker"
else
  # Prefer local MySQL if reachable
  if nc -z 127.0.0.1 3306 >/dev/null 2>&1; then
    DB_MODE="--db-local"
  else
    echo "[ERROR] Aucun mode DB disponible automatiquement. Installez/lancez Docker ou MySQL local, ou appelez scripts/install-and-run.sh avec --db-docker ou --db-local." >&2
    exit 1
  fi
fi

exec "$NEW_SCRIPT" "$DB_MODE" "${FORWARD_FLAGS[@]}"