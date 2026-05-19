#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v firebase >/dev/null 2>&1; then
  echo "firebase-tools kuruluyor..."
  npm install -g firebase-tools
fi

echo "Firebase Auth Emulator başlatılıyor (9099)..."
echo "Emulator UI: http://127.0.0.1:4000"
exec firebase emulators:start --only auth --project demo-youhavetosay
