#!/usr/bin/env bash
set -euo pipefail

# iOS Simulator'da Türkçe Q klavyeyi varsayılan yapar.
# Kullanım: ./scripts/setup-turkish-keyboard-ios.sh

UDID=$(xcrun simctl list devices booted -j \
  | python3 -c "import sys,json
d=json.load(sys.stdin)
devs=[x for v in d['devices'].values() for x in v if x.get('state')=='Booted']
print(devs[0]['udid'] if devs else '')")

if [[ -z "$UDID" ]]; then
  echo "Açık iOS Simulator bulunamadı. Önce simülatörü başlat."
  exit 1
fi

DEV_PREFS="$HOME/Library/Developer/CoreSimulator/Devices/$UDID/data/Library/Preferences"
GP="$DEV_PREFS/.GlobalPreferences.plist"
KP="$DEV_PREFS/com.apple.keyboard.preferences.plist"

TURKISH_KB='tr_TR@sw=Turkish-Q;hw=Automatic;ml=1'

plutil -replace AppleLocale -string tr_TR "$GP"
plutil -replace AppleLanguages -json '["tr-TR","en-TR"]' "$GP"
plutil -replace AppleKeyboards -json "[\"$TURKISH_KB\",\"en_US@sw=QWERTY;hw=Automatic;ml=1\",\"emoji@sw=Emoji\"]" "$GP"
plutil -replace ApplePasscodeKeyboards -json "[\"$TURKISH_KB\",\"en_US@sw=QWERTY;hw=Automatic;ml=1\",\"emoji@sw=Emoji\"]" "$GP"

if [[ -f "$KP" ]]; then
  plutil -replace KeyboardLastUsed -string "$TURKISH_KB" "$KP"
  plutil -replace KeyboardsCurrentAndNext -json "[\"$TURKISH_KB\",\"$TURKISH_KB\"]" "$KP"
fi

# Mac klavyesi yerine simülatörün Türkçe ekran klavyesini kullan
defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool false

xcrun simctl spawn "$UDID" launchctl stop com.apple.SpringBoard 2>/dev/null || true

echo "✓ iOS Simulator ($UDID) Türkçe Q klavye olarak ayarlandı."
echo "  - Locale: tr_TR"
echo "  - Ekran klavyesi: açık (Hardware Keyboard kapalı)"
echo ""
echo "Mac klavyesi ile yazmak istersen:"
echo "  Sistem Ayarları → Klavye → Giriş Kaynakları → Türkçe Q ekle"
echo "  Simulator menü: I/O → Keyboard → Connect Hardware Keyboard ✓"
