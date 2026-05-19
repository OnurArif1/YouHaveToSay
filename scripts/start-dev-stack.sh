#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> PostgreSQL (docker compose)..."
docker compose up -d

echo "==> Firebase Auth Emulator..."
if ! command -v firebase >/dev/null 2>&1; then
  npm install -g firebase-tools
fi

# Emulator arka planda
if ! lsof -i :9099 >/dev/null 2>&1; then
  firebase emulators:start --only auth --project demo-youhavetosay &
  EMULATOR_PID=$!
  echo "Emulator PID: $EMULATOR_PID (UI: http://127.0.0.1:4000)"
  sleep 4
else
  echo "Auth emulator zaten çalışıyor (9099)."
fi

echo "==> API..."
dotnet run --project src/YouHaveToSay.Api
