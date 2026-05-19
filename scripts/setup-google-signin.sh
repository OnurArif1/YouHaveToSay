#!/usr/bin/env bash
# Gerçek Google hesap seçici (Gmail listesi) için tek seferlik kurulum.
# Bu script Terminal.app'te çalıştırılmalı (tarayıcıda Google girişi açılır).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MOBILE="$ROOT/mobile"
PLIST="$MOBILE/ios/Runner/GoogleService-Info.plist"
CREDS="$ROOT/firebase-credentials.json"

export PATH="$PATH:$HOME/.pub-cache/bin"

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ -s "$(brew --prefix 2>/dev/null)/opt/nvm/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  . "$(brew --prefix)/opt/nvm/nvm.sh"
  nvm use 22 2>/dev/null || nvm use default 2>/dev/null || true
fi

echo "=== Söz Sende — Google Sign-In kurulumu (Node $(node -v)) ==="
echo ""

if [[ ! -t 0 ]]; then
  echo "Bu scripti macOS Terminal'den çalıştırın (Cursor agent değil):"
  echo "  cd $ROOT && ./scripts/setup-google-signin.sh"
  exit 1
fi

if ! command -v firebase >/dev/null 2>&1; then
  echo "firebase-tools kuruluyor..."
  npm install -g firebase-tools
fi

dart pub global activate flutterfire_cli

echo ""
echo "1/4 Firebase'e giriş (tarayıcı açılacak)..."
firebase login

echo ""
echo "2/4 Flutter Firebase yapılandırması..."
cd "$MOBILE"
flutterfire configure --yes --platforms=ios,android

echo ""
echo "3/4 iOS URL scheme..."
"$ROOT/scripts/apply-ios-google-url-scheme.sh"

PROJECT_ID="$(grep -o 'projectId: .*' lib/firebase_options.dart 2>/dev/null | head -1 | sed "s/.*'\([^']*\)'.*/\1/" || true)"
if [[ -n "$PROJECT_ID" && "$PROJECT_ID" != *REPLACE* ]]; then
  echo ""
  echo "API appsettings için ProjectId: $PROJECT_ID"
fi

echo ""
echo "4/4 Firebase Console adımları:"
echo "  → https://console.firebase.google.com/"
echo "  → Authentication → Sign-in method → Google → Etkinleştir"
echo "  → Project settings → Service accounts → Generate new private key"
echo "  → İndirilen JSON dosyasını şuraya kopyala:"
echo "    $CREDS"
echo ""

if [[ ! -f "$CREDS" ]]; then
  echo "Uyarı: firebase-credentials.json henüz yok — API Google token doğrulayamaz."
else
  echo "firebase-credentials.json bulundu."
fi

echo ""
echo "Tamam. Şimdi:"
echo "  dotnet run --project src/YouHaveToSay.Api"
echo "  cd mobile && flutter run"
