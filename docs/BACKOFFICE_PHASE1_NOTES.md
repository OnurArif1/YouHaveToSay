# Backoffice — Phase 1 Implementation Notes

## Existing Backend Architecture

Clean Architecture layers:

- `YouHaveToSay.Domain` — `User`, `Poll`, `PollOption`, `Vote`; `AuditableEntity` provides `CreatedAt`, `IsActive`
- `YouHaveToSay.Application` — DTOs, interfaces, exceptions
- `YouHaveToSay.Infrastructure` — EF Core `AppDbContext`, `AuthService`, `JwtTokenService`, `ComparisonService`, `PollService`
- `YouHaveToSay.Api` — Controllers, `CurrentUserService`, JWT middleware, `ExceptionHandlingMiddleware`

Dependency direction: Api → Infrastructure → Application → Domain.

## Poll / PollOption / Vote Model

| Product term | Backend entity | Key fields |
|---|---|---|
| Comparison | `Poll` | `QuestionTr`, `QuestionEn`, `Category`, `IsActive`, `CreatedAt` |
| Option | `PollOption` | `OptionTextTr`, `OptionTextEn`, `PollId`, `IsActive` |
| Vote | `Vote` | `UserId`, `PollId`, `SelectedOptionId` (unique per user+poll) |

Notes:

- Mobile/API DTOs map `QuestionTr/En` → `TitleTr/En`.
- `PollOption` has no `ImageUrl` column yet — add via migration for backoffice.
- Feed requires `Poll.IsActive` and exactly two active options.
- Vote percentages already computed in `ComparisonService.BuildVoteResultAsync` (2 decimal places).

## JWT Auth

- Login: `POST /api/auth/register-or-login` with Firebase token (dev: `dev:{uid}:{email}`).
- JWT claims: `NameIdentifier` (user id), `Email`, `firebase_uid`.
- `ICurrentUserService` exposes `UserId` only today — extend with `Email` for admin checks.
- Mobile endpoints use `[Authorize]` on `ComparisonsController` and `PollsController`.

## Mobile / Public API (must not break)

| Route | Service |
|---|---|
| `GET /api/comparisons/feed` | `IComparisonService.GetFeedAsync` |
| `POST /api/comparisons/{id}/vote` | `IComparisonService.VoteAsync` |
| `GET /api/comparisons/voted` | `IComparisonService.GetVotedHistoryAsync` |
| `GET /api/polls/next` | `IPollService.GetNextPollAsync` |
| `POST /api/polls/{id}/vote` | `IPollService.VoteAsync` |

## Backend Extension Points

1. **Admin authorization** — `BackofficeOptions` (`AdminEmails`), `IBackofficeAuthorizationService` or `BackofficeAdmin` authorization policy/handler; read email from `ClaimTypes.Email`; return 403 via `ForbiddenAppException` or policy failure.
2. **Backoffice DTOs** — new folder `Application/Backoffice/` (separate from mobile `Comparisons` DTOs).
3. **Backoffice service** — `IBackofficeComparisonService` + `BackofficeComparisonService` in `Infrastructure/Backoffice/`.
4. **Backoffice controller** — `BackofficeComparisonsController` at `/api/backoffice` with `[Authorize(Policy = BackofficeAdmin)]`.
5. **Poll/PollOption updates** — extend `Poll`/`PollOption` via EF; update by id preserving option IDs and votes.
6. **Vote aggregation** — reuse grouping pattern from `ComparisonService.BuildVoteResultAsync`.

Register new services in `Infrastructure/DependencyInjection.cs`. Configure `Backoffice` section in `appsettings.json`.

## Frontend Extension Points

- New root folder: `backoffice/` (Vue 3 + Vite + TypeScript + Tailwind).
- Auth: reuse Firebase login → API JWT; store token in `localStorage` or `sessionStorage`.
- `services/apiClient.ts` — Bearer interceptor, global 401/403 handling.
- `services/backofficeApi.ts` — typed methods for `/api/backoffice/*`.
- `stores/authStore.ts` + Vue Router guards for protected routes.
- Pages: Login, Dashboard, Comparisons list/create/edit/results, Users summary.

`mobile/` Flutter app must remain untouched.

## Gaps to Address in Later Phases

- No `backoffice/` folder yet.
- No admin config or policy.
- No `ForbiddenAppException` (403).
- `ICurrentUserService` lacks `Email`.
- `PollOption.ImageUrl` not in schema.
