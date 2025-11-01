#!/bin/bash
# Deprecated wrapper: use scripts/db-docker-setup.sh instead
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
echo "⚠️  scripts/bootstrap-db.sh est déprécié. Utilisez: scripts/db-docker-setup.sh"
exec "$ROOT_DIR/scripts/db-docker-setup.sh" "$@"