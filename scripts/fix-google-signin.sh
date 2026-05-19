#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
# shellcheck source=/dev/null
. "$(brew --prefix)/opt/nvm/nvm.sh"
nvm use 22

echo "=== Google Sign-In düzeltme ==="
echo ""
echo "Tarayıcıda Firebase Authentication açılıyor..."
open "https://console.firebase.google.com/project/soz-sende-app/authentication/providers"

echo ""
echo "Yapmanız gerekenler:"
echo "  1) 「Başlayın」 (ilk kez görünüyorsa)"
echo "  2) Google satırı → Etkinleştir → Kaydet"
echo ""
read -r -p "Bunları yaptıktan sonra Enter'a basın..."

"$ROOT/scripts/refresh-google-config.sh"

if grep -q CLIENT_ID "$ROOT/mobile/ios/Runner/GoogleService-Info.plist"; then
  echo ""
  echo "Başarılı! Şimdi:"
  echo "  dotnet run --project src/YouHaveToSay.Api"
  echo "  cd mobile && flutter run"
else
  echo ""
  echo "HATA: GoogleService-Info.plist içinde CLIENT_ID yok."
  echo "Firebase Console'da Google'ı etkinleştirdiğinizden emin olun."
  exit 1
fi
