#!/usr/bin/env bash
set -euo pipefail

# Android Emulator'da Türkçe locale ve klavye ayarlar.
# Kullanım: ./scripts/setup-turkish-keyboard-android.sh

if ! command -v adb &>/dev/null; then
  echo "adb bulunamadı. Android SDK platform-tools PATH'e ekleyin."
  echo "Örnek: export PATH=\"\$PATH:\$HOME/Library/Android/sdk/platform-tools\""
  exit 1
fi

DEVICE=$(adb devices | awk 'NR>1 && $2=="device" {print $1; exit}')
if [[ -z "$DEVICE" ]]; then
  echo "Çalışan Android emulator bulunamadı."
  exit 1
fi

echo "Cihaz: $DEVICE"

# Türkiye locale
adb shell settings put system system_locales tr-TR
adb shell setprop persist.sys.language tr
adb shell setprop persist.sys.country TR

# Gboard klavye ayarları ekranını aç (Türkçe'yi elle eklemediysen)
adb shell am start -a android.settings.INPUT_METHOD_SETTINGS 2>/dev/null || true

echo "✓ Android emulator Türkçe locale ayarlandı (tr-TR)."
echo "  Gboard açıldıysa: Languages → Add keyboard → Turkish (Q) seç."
