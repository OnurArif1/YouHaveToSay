# Phase 1 — Extension Points (Mevcut Mimari)

Bu belge Phase 1 çıktısıdır. Üretim kodu değiştirilmedi.

## Backend extension points

### Domain entities to extend
- `Poll` — `QuestionTr`, `QuestionEn`, `Options`, `Votes`; karşılaştırma için `Category` alanı Phase 5+ eklenebilir (şu an yok).
- `PollOption` — `OptionTextTr/En`; `ImageUrl` ileride eklenebilir.
- `Vote` — `(UserId, PollId)` unique; tekrar oy kuralı korunmalı.
- `User` — `FirebaseUserId` unique; auth akışına dokunulmamalı.
- `AuditableEntity` — `CreatedAt`, `IsActive`; feed sıralaması `CreatedAt DESC` kullanır.

### Application DTOs/services to extend
- Mevcut: `PollDto`, `PollOptionDto`, `VoteRequest`, `IPollService`.
- Güvenli ekleme yeri: `Application/Comparisons/` — `ComparisonDto`, `ComparisonFeedResponseDto`, `IComparisonService`.
- Ortak: `ICurrentUserService`, `AppException` hiyerarşisi (`ConflictAppException` → `ALREADY_VOTED`).

### Infrastructure services to extend
- `PollService` — `GetNextPollAsync`, `VoteAsync`; comparison feed/vote mantığı `ComparisonService` ile paylaşılabilir veya içten çağrılabilir.
- `DependencyInjection.AddInfrastructure` — yeni `IComparisonService` kaydı.
- `DevelopmentDataSeeder` — Phase 5’te 30+ iki seçenekli anket.
- `AppDbContext` — şema değişikliği Phase 2’de gerekmez; `Category` sonraki fazlarda migration ile.

### API controllers to extend
- Mevcut: `AuthController`, `PollsController` — korunacak.
- Yeni: `ComparisonsController` — `GET /api/comparisons/feed`, `POST /api/comparisons/{id}/vote`.
- `Program.cs` — controller discovery otomatik; auth middleware değişmez.

## Mobile extension points

### Existing PollBloc usage
- `PollLoadNextRequested`, `PollVoteSubmitted`; `PollScreen` authenticated root’ta kullanılıyor.
- Phase 7+ için `ComparisonFeedBloc` eklenebilir veya `PollBloc` genişletilebilir; en az kesinti: `features/comparisons/` veya `polls/` altında yeni bloc.

### Existing PollScreen usage
- `app.dart` → `AuthStatus.authenticated` → `PollScreen`.
- Feed UI Phase 8’de `ComparisonFeedScreen` ile değiştirilebilir; `app.dart` routing tek satır güncelleme.

### Existing repository methods
- `PollsRepository.getNextPoll()`, `vote()` — korunacak.
- Yeni: `getComparisonFeed(limit)`, `voteComparison(id, optionId)` — aynı `Dio` instance.

### Existing DTO mapping
- `PollDto.fromJson` → `Poll`; pattern `features/polls/data/models/` altında tekrarlanabilir.

### Existing auth/token behavior
- `AuthBloc`, `AuthRepositoryImpl._exchangeToken`, `AuthTokenStorage`, `api_client.dart` Bearer interceptor — dokunulmamalı.
- `FirebaseTokenProvider` — sadece register-or-login path’inde.

## Mevcut akış özeti

| Akış | Konum |
|------|--------|
| Firebase → API JWT | `AuthService`, `AuthRepositoryImpl` |
| Sonraki anket | `GET /api/polls/next` → `PollService.GetNextPollAsync` |
| Oy | `POST /api/polls/{id}/vote` → unique `(UserId, PollId)` |
| Tek oy kuralı | `PollService` + DB index |
