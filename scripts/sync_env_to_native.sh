#!/usr/bin/env bash
# Syncs root `.env` Google API keys into Android local.properties and iOS Local.xcconfig.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE — copy .env.example to .env and add your keys."
  exit 1
fi

get_env() {
  local key="$1"
  local value
  value="$(grep -E "^${key}=" "$ENV_FILE" | tail -n 1 | cut -d '=' -f2-)"
  # Trim surrounding quotes if present
  value="${value%\"}"
  value="${value#\"}"
  value="${value%\'}"
  value="${value#\'}"
  printf '%s' "$value"
}

MAPS_KEY="$(get_env GOOGLE_MAPS_API_KEY)"
PLACES_KEY="$(get_env GOOGLE_PLACES_API_KEY)"

if [[ -z "$MAPS_KEY" || "$MAPS_KEY" == your_* ]]; then
  echo "GOOGLE_MAPS_API_KEY is missing or still a placeholder in .env"
  exit 1
fi

if [[ -z "$PLACES_KEY" ]]; then
  PLACES_KEY="$MAPS_KEY"
fi

# --- Android: upsert into local.properties (keep sdk.dir / flutter.sdk) ---
ANDROID_PROPS="$ROOT_DIR/android/local.properties"
mkdir -p "$(dirname "$ANDROID_PROPS")"
touch "$ANDROID_PROPS"

tmp="$(mktemp)"
grep -v -E '^(MAPS_API_KEY|PLACES_API_KEY|GOOGLE_MAPS_API_KEY|GOOGLE_PLACES_API_KEY)=' "$ANDROID_PROPS" >"$tmp" || true
{
  cat "$tmp"
  echo "MAPS_API_KEY=$MAPS_KEY"
  echo "PLACES_API_KEY=$PLACES_KEY"
} >"$ANDROID_PROPS"
rm -f "$tmp"
echo "Updated android/local.properties"

# --- iOS: write Local.xcconfig (gitignored) ---
IOS_XCCONFIG="$ROOT_DIR/ios/Flutter/Local.xcconfig"
mkdir -p "$(dirname "$IOS_XCCONFIG")"
cat >"$IOS_XCCONFIG" <<EOF
GOOGLE_MAPS_API_KEY=$MAPS_KEY
GOOGLE_PLACES_API_KEY=$PLACES_KEY
EOF
echo "Updated ios/Flutter/Local.xcconfig"

echo "Done. Rebuild the app so native Maps picks up the keys."
