# YouHaveToSay

Türkiye odaklı günlük anket/oylama mobil uygulaması.

## Phase 1 — Veritabanı

### Çözüm yapısı

```
src/
  YouHaveToSay.Domain/          # Entity modelleri
  YouHaveToSay.Infrastructure/  # DbContext, EF konfigürasyonları, migration'lar
  YouHaveToSay.Api/             # Startup (EF CLI için)
```

### Veritabanı şeması

| Tablo       | Açıklama |
|------------|----------|
| `Users`    | Firebase Auth ile eşleşen kullanıcılar (`FirebaseUserId` unique) |
| `Polls`    | TR/EN soru metinleri |
| `PollOptions` | Anket seçenekleri (Poll → 1-N) |
| `Votes`    | Kullanıcı oyları; **unique (UserId, PollId)** ile tekrar oy engellenir |

Tüm tablolarda audit alanları: `CreatedAt`, `IsActive`.

### Veritabanı

**PostgreSQL** (Npgsql + EF Core). Yerel geliştirme için Docker:

### Yerel PostgreSQL (Docker)

```bash
docker compose up -d
```

### EF Core migration komutları

```bash
# EF CLI (bir kez)
dotnet tool install --global dotnet-ef

# İlk migration oluşturma
dotnet ef migrations add InitialCreate \
  --project src/YouHaveToSay.Infrastructure \
  --startup-project src/YouHaveToSay.Api \
  --output-dir Persistence/Migrations

# Veritabanına uygulama
dotnet ef database update \
  --project src/YouHaveToSay.Infrastructure \
  --startup-project src/YouHaveToSay.Api
```

### Testler

```bash
docker compose up -d
dotnet test
```

Doğrulanan kurallar:
- Audit alanları (`CreatedAt`, `IsActive`) otomatik set edilir
- `FirebaseUserId` benzersiz olmalıdır
- Aynı kullanıcı aynı ankete ikinci kez oy veremez (`UserId` + `PollId` unique)

### Bağlantı dizesi

`appsettings.json` → `ConnectionStrings:DefaultConnection`:

```json
"Host=localhost;Port=5432;Database=YouHaveToSay;Username=postgres;Password=postgres"
```

Production ortamında şifre ve host bilgilerini ortam değişkeni veya gizli yapılandırma ile verin.

## Phase 2 — REST API

### Katmanlar

```
src/
  YouHaveToSay.Domain/
  YouHaveToSay.Application/    # DTO, arayüzler, iş kuralları sözleşmeleri
  YouHaveToSay.Infrastructure/ # EF, Firebase, JWT, servis implementasyonları
  YouHaveToSay.Api/            # Controllers, middleware
```

### API uç noktaları

| Metot | Yol | Auth | Açıklama |
|-------|-----|------|----------|
| POST | `/api/auth/register-or-login` | Hayır | Firebase ID token alır, kullanıcıyı oluşturur/günceller, **custom JWT** döner |
| GET | `/api/polls/next` | Bearer JWT | Kullanıcının oy vermediği bir sonraki aktif anketi getirir |
| POST | `/api/polls/{id}/vote` | Bearer JWT | `{ "selectedOptionId": "..." }` ile oy kaydeder |

### Auth akışı

1. Mobil uygulama Firebase ile giriş yapar → **Firebase ID Token**
2. Token `POST /api/auth/register-or-login` gövdesine gönderilir
3. API token'ı doğrular, SQL'de kullanıcı oluşturur/bulur
4. Yanıt: `accessToken` (API JWT), `expiresAt`, `user`

**Geliştirme modu** (`Firebase:Enabled: false`): test token formatı:

```
dev:{firebaseUserId}:{email}
```

Örnek: `dev:abc123:user@test.com`

### Production Firebase

`appsettings.json`:

```json
"Firebase": {
  "Enabled": true,
  "ProjectId": "your-firebase-project-id",
  "CredentialsPath": "firebase-credentials.json"
}
```

Service account JSON dosyasını proje köküne koyun (git'e eklemeyin).

### JWT yapılandırması

```json
"Jwt": {
  "Secret": "en-az-32-karakterlik-gizli-anahtar",
  "Issuer": "YouHaveToSay",
  "Audience": "YouHaveToSay",
  "ExpirationMinutes": 10080
}
```

### API'yi çalıştırma

```bash
docker compose up -d
dotnet ef database update --project src/YouHaveToSay.Infrastructure --startup-project src/YouHaveToSay.Api
dotnet run --project src/YouHaveToSay.Api
```

Development ortamında örnek anketler otomatik seed edilir.

### Swagger

Development ortamında:

- **UI:** http://localhost:5106/swagger
- **OpenAPI JSON:** http://localhost:5106/swagger/v1/swagger.json

1. `POST /api/auth/register-or-login` ile giriş yapın (dev token: `dev:user1:test@example.com`)
2. Yanıttaki `accessToken` değerini kopyalayın
3. Swagger UI'da **Authorize** → `Bearer {token}` girin
4. Korumalı poll endpoint'lerini test edin

## Phase 3 — Flutter mobil uygulama

Kaynak: `mobile/`

```bash
cd mobile
flutter pub get
flutter run
```

Detaylar: [mobile/README.md](mobile/README.md)

### Örnek istekler

```bash
# Giriş (geliştirme token)
curl -X POST http://localhost:5000/api/auth/register-or-login \
  -H "Content-Type: application/json" \
  -d '{"firebaseToken":"dev:test-user-1:test@example.com"}'

# Sonraki anket
curl http://localhost:5000/api/polls/next \
  -H "Authorization: Bearer {accessToken}"

# Oy ver
curl -X POST http://localhost:5000/api/polls/{pollId}/vote \
  -H "Authorization: Bearer {accessToken}" \
  -H "Content-Type: application/json" \
  -d '{"selectedOptionId":"{optionId}"}'
```

Anket kalmadığında `404` + `{ "code": "NO_MORE_POLLS", ... }` döner.
