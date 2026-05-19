#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MOBILE="$ROOT/mobile"

export PATH="$PATH:$HOME/.pub-cache/bin"

echo "==> flutterfire_cli kuruluyor..."
dart pub global activate flutterfire_cli

if ! command -v flutterfire >/dev/null 2>&1; then
  echo "Hata: flutterfire bulunamadı. Şunu .zshrc veya .bashrc dosyana ekle:"
  echo '  export PATH="$PATH:$HOME/.pub-cache/bin"'
  exit 1
fi

echo ""
echo "==> Firebase projesi bağlanıyor (etkileşimli)..."
echo "    - iOS ve Android seç"
echo "    - Bundle ID: com.youhavetosay.youHaveToSay"
echo ""
cd "$MOBILE"
flutterfire configure

echo ""
echo "==> iOS Google URL scheme uygulanıyor..."
"$ROOT/scripts/apply-ios-google-url-scheme.sh" || true

echo ""
echo "==> Tamam. Şimdi:"
echo "  cd mobile"
echo "  flutter run"
echo ""
echo "Firebase Console → Authentication → Sign-in method → Google → Enable"
