# YouHaveToSay — Mobile (Flutter)

## Gereksinimler

- Flutter 3.41+
- API çalışıyor olmalı (`docker compose up -d` + `dotnet run --project src/YouHaveToSay.Api`)

## Çalıştırma (geliştirme)

Varsayılan olarak **dev auth** açıktır (`USE_DEV_AUTH=true`). Firebase yapılandırması gerekmez; API `dev:uid:email` token formatını kabul eder.

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
