#!/bin/bash
set -euo pipefail

# Helper to run Flutter app on Android Emulator with correct API_BASE_URL.
# Default API for Android emulator points to host machine via 10.0.2.2:8000

API_BASE_URL="${API_BASE_URL:-http://10.0.2.2:8000}"
if [[ "${1:-}" == "--api" && -n "${2:-}" ]]; then
  API_BASE_URL="$2"
  shift 2
fi

echo "Using API_BASE_URL=$API_BASE_URL"

# Move to mobile app root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${SCRIPT_DIR}/.."
cd "$APP_DIR"

echo "Fetching Flutter dependencies..."
flutter pub get

echo "Checking for Android device..."
if ! flutter devices | grep -i "android" >/dev/null; then
  echo "No Android device detected. Trying to start an emulator..."

  CANDIDATE_SDK_DIRS=(
    "${ANDROID_HOME:-}"
    "$HOME/Library/Android/sdk"
    "/Users/$USER/Library/Android/sdk"
  )

  EMULATOR_BIN=""
  for d in "${CANDIDATE_SDK_DIRS[@]}"; do
    if [[ -x "$d/emulator/emulator" ]]; then
      EMULATOR_BIN="$d/emulator/emulator"
      break
    fi
  done

  if [[ -z "$EMULATOR_BIN" ]]; then
    echo "Android emulator not found."
    echo "Open Android Studio > Tools > Device Manager and start an AVD,"
    echo "or ensure ANDROID_HOME is set and SDK is installed."
    exit 1
  fi

  AVD_LIST="$($EMULATOR_BIN -list-avds || true)"
  if [[ -z "$AVD_LIST" ]]; then
    echo "No AVD found. Create one in Android Studio (Device Manager) or via avdmanager."
    exit 1
  fi

  AVD_NAME="$(echo "$AVD_LIST" | head -n1)"
  echo "Starting emulator: $AVD_NAME"
  "$EMULATOR_BIN" -avd "$AVD_NAME" -netdelay none -netspeed full >/dev/null 2>&1 &

  echo "Waiting for emulator to boot..."
  for i in {1..60}; do
    if flutter devices | grep -i "android" >/dev/null; then
      break
    fi
    sleep 2
  done
fi

DEVICE_ID="$(flutter devices | awk '/android/i {print $1; exit}')"
if [[ -z "$DEVICE_ID" ]]; then
  echo "Android device not detected. Abort."
  exit 1
fi

echo "Running app on device: $DEVICE_ID"
flutter run -d "$DEVICE_ID" --dart-define "API_BASE_URL=$API_BASE_URL" "$@"
