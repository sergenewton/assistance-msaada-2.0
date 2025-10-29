#!/bin/bash
set -euo pipefail

# Helper to run Flutter app on iOS Simulator with correct API_BASE_URL.
# Default API for iOS simulator can use localhost:8000.

API_BASE_URL="${API_BASE_URL:-http://localhost:8000}"
if [[ "${1:-}" == "--api" && -n "${2:-}" ]]; then
  API_BASE_URL="$2"
  shift 2
fi

echo "Using API_BASE_URL=$API_BASE_URL"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${SCRIPT_DIR}/.."
cd "$APP_DIR"

echo "Fetching Flutter dependencies..."
flutter pub get

echo "Ensuring iOS Simulator is running..."
if ! xcrun simctl list | grep -q "Booted"; then
  open -a Simulator
  # Wait briefly for boot
  sleep 5
fi

echo "Detecting iOS simulator device..."
flutter devices
DEVICE_ID="$(flutter devices | awk '/iOS Simulator|iPhone/ {print $1; exit}')"
if [[ -z "$DEVICE_ID" ]]; then
  echo "No iOS simulator detected. Open Xcode > Settings > Platforms to install iOS simulators."
  exit 1
fi

echo "Running app on device: $DEVICE_ID"
flutter run -d "$DEVICE_ID" --dart-define "API_BASE_URL=$API_BASE_URL" "$@"
