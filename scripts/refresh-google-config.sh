#!/usr/bin/env bash
# Google provider Console'da etkinleştirildikten sonra çalıştırın.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
# shellcheck source=/dev/null
. "$(brew --prefix)/opt/nvm/nvm.sh"
nvm use 22
export PATH="$PATH:$HOME/.pub-cache/bin"

cd "$ROOT/mobile"
flutterfire configure --yes --project=soz-sende-app --platforms=ios,android
"$ROOT/scripts/apply-ios-google-url-scheme.sh"

if grep -q CLIENT_ID "$ROOT/mobile/ios/Runner/GoogleService-Info.plist" 2>/dev/null; then
  echo "Google OAuth yapılandırması tamam."
  echo "iosClientId firebase_options.dart içine yazıldı — flutter run ile yeniden başlatın."
else
  echo "Uyarı: GoogleService-Info.plist içinde CLIENT_ID yok."
  echo "Firebase Console → Authentication → Google → Etkinleştir"
fi
