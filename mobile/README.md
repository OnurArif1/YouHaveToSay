# YouHaveToSay — Mobile (Flutter)

## Gereksinimler

- Flutter 3.41+
- API çalışıyor olmalı (`docker compose up -d` + `dotnet run --project src/YouHaveToSay.Api`)

## Simülatörde Türkçe klavye

iOS Simulator açıkken proje kökünden:

```bash
./scripts/setup-turkish-keyboard-ios.sh
```

Bu script:
- Locale'i `tr_TR` yapar
- Varsayılan klavyeyi **Türkçe Q** seçer
- Mac klavyesi eşlemesini kapatır → simülatörün Türkçe ekran klavyesi kullanılır (`ğ`, `ü`, `ş`, `ı`, `ö`, `ç` doğru çalışır)

**Mac klavyesi ile yazmak istersen:**
1. Sistem Ayarları → Klavye → Giriş Kaynakları → **Türkçe Q** ekle
2. Simulator menü: **I/O → Keyboard → Connect Hardware Keyboard** ✓

Android için: `./scripts/setup-turkish-keyboard-android.sh` (adb gerekir)

## Google ile giriş (varsayılan)

Ana ekranda **「Google ile devam et」** — Gmail hesabını seçersin.

### Geliştirme (otomatik — Firebase Console gerekmez)

Debug modda uygulama **Firebase Auth Emulator** kullanır. Proje kökünden:

```bash
./scripts/start-firebase-emulator.sh   # terminal 1
dotnet run --project src/YouHaveToSay.Api   # terminal 2
cd mobile && flutter run               # terminal 3
```

Veya tek komut: `./scripts/start-dev-stack.sh` (PostgreSQL + emulator + API)

### Production (gerçek Firebase)

1. [Firebase Console](https://console.firebase.google.com/) → proje
2. Authentication → Google → Etkinleştir
3. `flutterfire configure`
4. `flutter run --release`

Geliştirici e-posta girişi: `flutter run --dart-define=USE_DEV_AUTH=true`

## Çalıştırma (geliştirme)

```bash
cd mobile
flutter pub get
flutter run
```

### API adresi

| Platform | Varsayılan URL |
|----------|----------------|
| iOS Simulator | `http://localhost:5106` |
| Android Emulator | `http://10.0.2.2:5106` |

Özel URL:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5106
```

### Production Firebase

```bash
flutterfire configure
flutter run --dart-define=USE_DEV_AUTH=false
```

`lib/firebase_options.dart` dosyasını `flutterfire configure` ile güncelleyin.

## Proje yapısı

```
lib/
  core/           # config, network, theme, DI
  features/
    auth/         # Firebase + API JWT exchange
    polls/        # anket listeleme ve oy
  assets/translations/  # tr.json, en.json
```

## Özellikler

- TR / EN lokalizasyon (`easy_localization`)
- `flutter_bloc` state management
- `dio` + interceptor (API JWT + Firebase token header)
- `flutter_screenutil` responsive layout
- Oy sonrası animasyon ve sonraki ankete slide geçişi
