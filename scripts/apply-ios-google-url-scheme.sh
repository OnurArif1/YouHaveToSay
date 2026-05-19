#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GS_PLIST="$ROOT/mobile/ios/Runner/GoogleService-Info.plist"
INFO_PLIST="$ROOT/mobile/ios/Runner/Info.plist"

if [[ ! -f "$GS_PLIST" ]]; then
  echo "GoogleService-Info.plist yok. Önce Firebase Console'da Google'ı etkinleştirin,"
  echo "sonra: ./scripts/refresh-google-config.sh"
  exit 1
fi

CLIENT_ID="$(/usr/libexec/PlistBuddy -c 'Print :CLIENT_ID' "$GS_PLIST" 2>/dev/null || true)"
REVERSED_ID="$(/usr/libexec/PlistBuddy -c 'Print :REVERSED_CLIENT_ID' "$GS_PLIST" 2>/dev/null || true)"

if [[ -z "$CLIENT_ID" || -z "$REVERSED_ID" ]]; then
  echo "GoogleService-Info.plist içinde CLIENT_ID / REVERSED_CLIENT_ID yok."
  echo "Firebase Console → Authentication → Google → Etkinleştir"
  exit 1
fi

# GIDClientID (Google Sign-In SDK)
if /usr/libexec/PlistBuddy -c 'Print :GIDClientID' "$INFO_PLIST" >/dev/null 2>&1; then
  /usr/libexec/PlistBuddy -c "Set :GIDClientID $CLIENT_ID" "$INFO_PLIST"
else
  /usr/libexec/PlistBuddy -c 'Add :GIDClientID string' "$INFO_PLIST"
  /usr/libexec/PlistBuddy -c "Set :GIDClientID $CLIENT_ID" "$INFO_PLIST"
fi

# URL scheme (OAuth geri dönüş)
if /usr/libexec/PlistBuddy -c 'Print :CFBundleURLTypes' "$INFO_PLIST" >/dev/null 2>&1; then
  echo "CFBundleURLTypes zaten var — GIDClientID güncellendi."
  exit 0
fi

/usr/libexec/PlistBuddy -c 'Add :CFBundleURLTypes array' "$INFO_PLIST"
/usr/libexec/PlistBuddy -c 'Add :CFBundleURLTypes:0 dict' "$INFO_PLIST"
/usr/libexec/PlistBuddy -c 'Add :CFBundleURLTypes:0:CFBundleTypeRole string Editor' "$INFO_PLIST"
/usr/libexec/PlistBuddy -c 'Add :CFBundleURLTypes:0:CFBundleURLSchemes array' "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:0 string $REVERSED_ID" "$INFO_PLIST"

echo "iOS yapılandırıldı:"
echo "  GIDClientID=$CLIENT_ID"
echo "  URL scheme=$REVERSED_ID"
