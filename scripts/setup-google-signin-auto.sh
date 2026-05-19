#!/usr/bin/env bash
# Tam kurulum: Firebase login → flutterfire → iOS scheme
# macOS Terminal'de çalıştırın; login sonrası otomatik devam eder.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MOBILE="$ROOT/mobile"
export PATH="$PATH:$HOME/.pub-cache/bin"

# Firebase CLI 15+ için Node >= 20 (nvm varsayılanı 14 ise hata verir)
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ -s "$(brew --prefix 2>/dev/null)/opt/nvm/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  . "$(brew --prefix)/opt/nvm/nvm.sh"
  nvm use 22 2>/dev/null || nvm use default 2>/dev/null || true
fi

NODE_MAJOR="$(node -v 2>/dev/null | sed 's/v//' | cut -d. -f1)"
if [[ -z "${NODE_MAJOR}" ]] || [[ "${NODE_MAJOR}" -lt 20 ]]; then
  echo "Hata: Node.js >= 20 gerekli (şu an: $(node -v 2>/dev/null || echo yok))"
  echo "Terminalde: nvm install 22 && nvm alias default 22"
  exit 1
fi

echo "=== Söz Sende — Google Sign-In otomatik kurulum (Node $(node -v)) ==="

if ! command -v firebase >/dev/null 2>&1; then
  npm install -g firebase-tools
fi
dart pub global activate flutterfire_cli

if ! firebase login:list 2>&1 | grep -q "@"; then
  echo ""
  echo ">>> Tarayıcıda Google / Firebase girişi yapın <<<"
  firebase login
fi

echo ""
echo "Firebase hesabı:"
firebase login:list

echo ""
echo ">>> flutterfire configure..."
cd "$MOBILE"
flutterfire configure --yes --platforms=ios,android

echo ""
echo ">>> iOS URL scheme..."
"$ROOT/scripts/apply-ios-google-url-scheme.sh"

PLIST="$MOBILE/ios/Runner/GoogleService-Info.plist"
if [[ -f "$PLIST" ]]; then
  echo ""
  echo "GoogleService-Info.plist oluşturuldu."
else
  echo "HATA: GoogleService-Info.plist bulunamadı."
  exit 1
fi

# appsettings ProjectId güncelle (flutterfire çıktısından)
if [[ -f "$MOBILE/lib/firebase_options.dart" ]]; then
  PID=$(grep "projectId:" "$MOBILE/lib/firebase_options.dart" | head -1 | sed -E "s/.*'([^']+)'.*/\1/")
  if [[ -n "$PID" && "$PID" != *REPLACE* ]]; then
    python3 - "$ROOT/src/YouHaveToSay.Api/appsettings.Development.json" "$PID" <<'PY'
import json, sys
path, pid = sys.argv[1], sys.argv[2]
with open(path) as f:
    data = json.load(f)
data.setdefault("Firebase", {})["ProjectId"] = pid
data["Firebase"]["Enabled"] = True
data["Firebase"]["UseEmulator"] = False
with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
print(f"API ProjectId = {pid}")
PY
  fi
fi

echo ""
echo "=== Son adımlar (manuel, bir kez) ==="
echo "1) https://console.firebase.google.com/"
echo "   → Authentication → Sign-in method → Google → Etkinleştir"
echo "2) Project settings → Service accounts → Generate new private key"
echo "   → Dosyayı kaydet: $ROOT/firebase-credentials.json"
echo ""
echo "Sonra:"
echo "  dotnet run --project src/YouHaveToSay.Api"
echo "  cd mobile && flutter run"
echo ""
echo "Kurulum (flutterfire + iOS) tamamlandı."
