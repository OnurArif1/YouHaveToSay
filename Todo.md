# YouHaveToSay — AI Implementation Guide
## Reels/Shorts Tarzı Karşılaştırmalı Oylama Sistemi

---

## MANDATORY OPERATING INSTRUCTIONS FOR CURSOR / AI AGENT

You are an AI implementation agent working on the **YouHaveToSay** mobile voting application.

Before writing a single line of code, read this entire document from start to finish. Do not skim. Do not skip sections.

These are your binding operating rules:

1. **You implement exactly ONE phase at a time.**
2. **You do not start Phase N+1 until every checklist item in Phase N is verified.**
3. **You do not break the existing login/authentication flow.**
4. **You do not rewrite the existing architecture.**
5. **You do not remove existing backend, mobile, Firebase, JWT, Poll, Vote, BLoC, repository, or API logic unless a phase explicitly tells you to change it.**
6. **You do not create speculative placeholder code.** Every line must be connected to the feature being implemented.
7. **You do not parallelize phases.**
8. **After each phase, you output a GATE REPORT.**
9. **If one checklist item fails, you stop, fix it, and re-run the checklist from the beginning.**
10. **You must preserve Clean Architecture on the backend and feature-first Clean Architecture + BLoC on Flutter.**

Failure to follow these rules will create a broken app. There are no exceptions.

---

# 0. Existing Application Context

The app already exists.

Current app name/context:

```text
YouHaveToSay
```

Current product direction:

```text
A Türkiye-focused daily voting / polling mobile application.
Users authenticate with Firebase, receive an API JWT from the backend, and vote once on active polls.
```

Current architecture:

| Layer | Technology | Role |
|---|---|---|
| Backend API | ASP.NET Core 9, EF Core, PostgreSQL | Authentication, poll rules, vote rules |
| Mobile App | Flutter 3.11+ | UI, Firebase/Google login, voting flow |
| Infrastructure | Docker Compose, PostgreSQL, Firebase | Database and identity provider |

Current backend structure:

```text
src/
├── YouHaveToSay.Domain
├── YouHaveToSay.Application
├── YouHaveToSay.Infrastructure
└── YouHaveToSay.Api
```

Current mobile structure:

```text
mobile/lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/
│   ├── di/
│   ├── network/
│   └── theme/
└── features/
    ├── auth/
    └── polls/
```

Current authentication flow:

```text
Flutter App
→ Firebase / Google Sign-In
→ Firebase ID Token
→ Backend POST /api/auth/register-or-login
→ Backend verifies Firebase token
→ Backend creates/fetches User
→ Backend returns API JWT
→ Flutter stores JWT
→ Flutter calls protected poll endpoints with Bearer JWT
```

Current poll endpoints:

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | `/api/auth/register-or-login` | No | Login/register with Firebase token |
| GET | `/api/polls/next` | Bearer JWT | Get next poll the user has not voted on |
| POST | `/api/polls/{id}/vote` | Bearer JWT | Submit a vote |

Current business rule:

```text
A user can vote only once per poll.
```

This rule is currently protected by:

- Application logic
- Database unique index on `(UserId, PollId)`

---

# 1. New Product Vision

The app will become a **Reels / Shorts style comparison voting application**.

The user will scroll vertically.  
Each swipe will reveal a new comparison card.

Examples:

```text
Blue vs Red
Opel vs Mercedes
Icardi vs Osimhen
Tea vs Coffee
iPhone vs Samsung
Summer vs Winter
```

The user sees two options and votes for one.

The experience must feel like:

```text
Open app
Swipe
Vote
See result
Swipe
Vote
See result
Repeat
```

The app should be fast, fun, addictive, and simple.

---

# 2. Core UX Principle

The app must not feel like a classic survey app.

It must feel like a short-form content feed.

Main UX rules:

1. One comparison per screen.
2. Vertical swipe to next comparison.
3. Two large tappable options.
4. Vote action must be instant.
5. Result must be shown immediately after vote.
6. User must never vote twice on the same comparison.
7. If no more comparisons exist, show a friendly empty state.
8. Mobile-first UI is mandatory.
9. The screen must be visually engaging.
10. Interactions should feel smooth and lightweight.

---

# 3. Protected Existing Systems

The following existing systems must not be broken:

| Existing System | Rule |
|---|---|
| Firebase login | Must keep working |
| Backend API JWT | Must keep working |
| AuthBloc | Must keep working |
| PollBloc | May be extended but not randomly rewritten |
| Dio API client | Must keep sending Bearer token |
| `GET /api/polls/next` | May remain for compatibility |
| `POST /api/polls/{id}/vote` | May remain or be extended |
| User one-vote-per-poll rule | Must remain enforced |
| PostgreSQL persistence | Must remain source of truth |
| Existing tests | Must continue passing or be intentionally updated |

If you need to modify an existing file, do it in the smallest possible way.

---

# 4. New Domain Language

From this point onward, the UI should be designed around **comparisons**.

Backend may still use `Poll`, `PollOption`, and `Vote` internally at first.

However, product language should be:

```text
Comparison
Comparison Option
Vote
Result
Feed
```

Recommended mapping:

| Existing Concept | New Product Concept |
|---|---|
| Poll | Comparison |
| PollOption | Comparison Option |
| Vote | Vote |
| PollScreen | Comparison Feed Screen |
| PollCard | Comparison Card |

Do not rename everything in the database immediately unless the phase explicitly says so.  
Use UI/domain abstraction first. Database refactor can be a later decision.

---

# 5. Target User Flow

The expected final flow:

```text
App opens
↓
Auth state checked
↓
If unauthenticated → Login screen
↓
If authenticated → Comparison Feed screen
↓
User sees one comparison
↓
User taps left or right option
↓
Vote is submitted
↓
Result percentage appears
↓
User swipes up
↓
Next comparison appears
```

---

# 6. Mandatory Phase Execution Process

For each phase, follow this exact sequence:

```text
STEP 1 — Read the phase completely.
STEP 2 — Identify all files that must be touched.
STEP 3 — Implement only this phase.
STEP 4 — Run or reason through the verification checklist.
STEP 5 — Write proof for every checklist item.
STEP 6 — Output GATE REPORT.
STEP 7 — Stop.
STEP 8 — Do not start the next phase until the user explicitly continues or the gate is approved.
```

Gate report format:

```text
=== GATE [N] REPORT ===
[✓] Item 1 — Proof sentence.
[✓] Item 2 — Proof sentence.
[✓] Item 3 — Proof sentence.

ALL ITEMS CONFIRMED. GATE [N] PASSED.
DO NOT START PHASE [N+1] UNTIL APPROVED.
```

If any item fails:

```text
=== GATE [N] REPORT ===
[✗] Item X — Failure reason.

GATE [N] FAILED.
STOPPING IMPLEMENTATION UNTIL THIS IS FIXED.
```

---

# 7. Architecture Rules

These rules apply to every phase.

## Rule A — Keep Clean Architecture

Backend must keep this dependency direction:

```text
Api
 → Infrastructure
   → Application
     → Domain
```

Domain must not depend on EF, Firebase, ASP.NET, or PostgreSQL.

## Rule B — Keep Flutter Feature Architecture

Flutter must stay feature-first:

```text
features/
├── auth/
└── polls/ or comparisons/
```

If creating a new `comparisons` feature, do not break `auth`.

## Rule C — Do Not Trust UI for Vote Rules

One-vote-per-comparison must be enforced in backend and database.

UI can disable buttons after vote, but backend remains source of truth.

## Rule D — Feed Must Be Cursor/Batch Friendly

The app should not call one API request for every single swipe forever.

Eventually, feed should load comparisons in batches.

## Rule E — No Duplicate Vote

If user already voted on a comparison:

- Backend must reject duplicate vote.
- UI must not allow second vote.
- If duplicate happens due to race condition, app must handle it gracefully.

## Rule F — Result Calculation Must Come From Backend

Vote percentages and total counts must come from backend, not from local fake calculation.

## Rule G — Mobile UX First

Every UI element must be designed for thumb usage.

Two options must be large, readable, and easy to tap.

## Rule H — One Phase Only

Do not implement future phase code early.

---

# PHASE 1 — Understand and Protect Current Architecture

## Objective

Before adding new features, inspect the existing backend and Flutter implementation and confirm the current architecture.

## What To Inspect

Backend:

```text
src/YouHaveToSay.Domain
src/YouHaveToSay.Application
src/YouHaveToSay.Infrastructure
src/YouHaveToSay.Api
```

Mobile:

```text
mobile/lib/features/auth
mobile/lib/features/polls
mobile/lib/core/network
mobile/lib/core/di
mobile/lib/app.dart
```

## Implementation Requirements

- Do not change business logic in this phase.
- Do not rename entities.
- Do not add new UI.
- Do not create new endpoints.
- Only document what exists and identify safe extension points.

## Expected Output

Create or update a short internal note in the implementation response listing:

```text
Backend extension points:
- Domain entities to extend
- Application DTOs/services to extend
- Infrastructure services to extend
- API controllers to extend

Mobile extension points:
- Existing PollBloc usage
- Existing PollScreen usage
- Existing repository methods
- Existing DTO mapping
- Existing auth/token behavior
```

## Verification Checklist

- [ ] Existing Firebase login flow is understood.
- [ ] Existing API JWT exchange is understood.
- [ ] Existing `GET /api/polls/next` behavior is understood.
- [ ] Existing `POST /api/polls/{id}/vote` behavior is understood.
- [ ] Existing `PollBloc` flow is understood.
- [ ] Existing one-vote-per-poll rule is identified.
- [ ] No production code was changed in this phase.

## GATE 1

You may not start Phase 2 until all checklist items are verified.

---

# PHASE 2 — Define Comparison Feed Product Model

## Objective

Create a clear product model for comparison-style voting without breaking the existing Poll model.

## Decision

Use existing `Poll` and `PollOption` as the backend foundation for now.

A comparison is a poll with exactly two primary options.

Example:

```text
Question: Which one do you prefer?
Option A: Opel
Option B: Mercedes
```

For the UI, expose it as:

```json
{
  "comparisonId": "uuid",
  "title": "Which one would you choose?",
  "leftOption": {
    "id": "uuid",
    "text": "Opel",
    "imageUrl": null
  },
  "rightOption": {
    "id": "uuid",
    "text": "Mercedes",
    "imageUrl": null
  },
  "category": "Cars",
  "hasVoted": false
}
```

## Backend Requirements

Add DTOs in Application layer:

```text
ComparisonDto
ComparisonOptionDto
ComparisonVoteRequest
ComparisonVoteResultDto
ComparisonFeedResponseDto
```

Recommended DTO fields:

```json
{
  "id": "pollId",
  "titleTr": "Hangisini seçerdin?",
  "titleEn": "Which one would you choose?",
  "leftOption": {
    "id": "optionId",
    "textTr": "Opel",
    "textEn": "Opel",
    "imageUrl": null
  },
  "rightOption": {
    "id": "optionId",
    "textTr": "Mercedes",
    "textEn": "Mercedes",
    "imageUrl": null
  },
  "category": "cars",
  "hasVoted": false
}
```

## Mobile Requirements

Add domain models or adapt existing poll model:

```text
Comparison
ComparisonOption
ComparisonVoteResult
```

Do not delete existing `Poll` classes unless the current codebase makes it safer to extend them.

## Verification Checklist

- [ ] Comparison DTOs exist in Application layer.
- [ ] Comparison model exists in Flutter domain layer or existing Poll model is safely adapted.
- [ ] Existing Poll endpoint still works.
- [ ] No database schema change was made yet.
- [ ] Auth flow is unchanged.
- [ ] App still builds.

## GATE 2

You may not start Phase 3 until all checklist items are verified.

---

# PHASE 3 — Backend Feed Endpoint

## Objective

Create a backend endpoint that returns a batch of active comparisons the user has not voted on.

## New Endpoint

```text
GET /api/comparisons/feed?limit=10
```

Auth:

```text
Bearer JWT required
```

## Behavior

The endpoint must:

1. Read current user from JWT.
2. Query active polls.
3. Exclude polls already voted by this user.
4. Only return polls that have exactly two active options.
5. Sort by `CreatedAt DESC`.
6. Return up to `limit` items.
7. Default `limit = 10`.
8. Maximum `limit = 25`.

## Response Example

```json
{
  "items": [
    {
      "id": "poll-id",
      "titleTr": "Hangisini seçerdin?",
      "titleEn": "Which one would you choose?",
      "leftOption": {
        "id": "option-a-id",
        "textTr": "Opel",
        "textEn": "Opel",
        "imageUrl": null
      },
      "rightOption": {
        "id": "option-b-id",
        "textTr": "Mercedes",
        "textEn": "Mercedes",
        "imageUrl": null
      },
      "category": "cars",
      "hasVoted": false
    }
  ],
  "hasMore": true
}
```

## Backend Implementation Notes

Recommended service method:

```text
IComparisonService.GetFeedAsync(userId, limit, cancellationToken)
```

Recommended controller:

```text
ComparisonsController
```

Do not remove `PollsController`.

## Verification Checklist

- [ ] `GET /api/comparisons/feed` exists.
- [ ] Endpoint requires Bearer JWT.
- [ ] Endpoint excludes comparisons already voted by the current user.
- [ ] Endpoint returns only two-option comparisons.
- [ ] Endpoint respects default limit 10.
- [ ] Endpoint enforces maximum limit 25.
- [ ] Existing `/api/polls/next` still works.
- [ ] Existing tests pass or new tests cover changed behavior.

## GATE 3

You may not start Phase 4 until all checklist items are verified.

---

# PHASE 4 — Backend Vote Endpoint with Result

## Objective

Create a vote endpoint for comparison cards that returns live result percentages immediately after vote.

## New Endpoint

```text
POST /api/comparisons/{id}/vote
```

Auth:

```text
Bearer JWT required
```

Request:

```json
{
  "selectedOptionId": "uuid"
}
```

Response:

```json
{
  "comparisonId": "uuid",
  "selectedOptionId": "uuid",
  "totalVotes": 1240,
  "leftOption": {
    "id": "uuid",
    "voteCount": 720,
    "percentage": 58.06
  },
  "rightOption": {
    "id": "uuid",
    "voteCount": 520,
    "percentage": 41.94
  }
}
```

## Behavior

The endpoint must:

1. Read current user from JWT.
2. Validate comparison exists and is active.
3. Validate selected option belongs to this comparison.
4. Ensure the comparison has exactly two options.
5. Prevent duplicate vote.
6. Save vote.
7. Return updated result counts and percentages.

## Duplicate Vote Handling

If user already voted:

```text
409 Conflict
code: ALREADY_VOTED
```

The mobile app should handle this gracefully.

## Percentage Rule

```text
percentage = optionVoteCount / totalVotes * 100
```

If totalVotes is zero, percentages must be 0.

After saving a vote, totalVotes should be at least 1.

## Verification Checklist

- [ ] `POST /api/comparisons/{id}/vote` exists.
- [ ] Endpoint requires Bearer JWT.
- [ ] Invalid comparison returns 404.
- [ ] Invalid selected option returns 400.
- [ ] Duplicate vote returns 409.
- [ ] Valid vote is persisted.
- [ ] Result counts are correct.
- [ ] Percentages are correct.
- [ ] Existing `/api/polls/{id}/vote` still works or is intentionally shared internally.
- [ ] Database unique index still protects duplicate votes.

## GATE 4

You may not start Phase 5 until all checklist items are verified.

---

# PHASE 5 — Seed Comparison Data for Development

## Objective

Create enough development comparisons to test the Reels/Shorts feed experience.

## Requirements

Development seed data must include at least 30 comparisons.

Categories:

```text
Colors
Cars
Football
Food
Technology
Daily Life
```

Examples:

| Category | Left | Right |
|---|---|---|
| Colors | Blue | Red |
| Cars | Opel | Mercedes |
| Football | Icardi | Osimhen |
| Food | Tea | Coffee |
| Technology | iPhone | Samsung |
| Daily Life | Summer | Winter |

## Backend Requirements

Update development seeder only.

Do not seed fake data in production.

Each comparison must:

- Be active.
- Have exactly two options.
- Have Turkish and English text.
- Have meaningful `CreatedAt`.
- Be compatible with the feed endpoint.

## Verification Checklist

- [ ] Development seeder creates at least 30 comparisons.
- [ ] Each seeded comparison has exactly two options.
- [ ] Seed data includes all required categories.
- [ ] Feed endpoint returns seeded comparisons.
- [ ] Production environment is not affected.
- [ ] Existing auth and vote rules are unchanged.

## GATE 5

You may not start Phase 6 until all checklist items are verified.

---

# PHASE 6 — Flutter Comparison Repository and API Client

## Objective

Connect Flutter to the new backend comparison endpoints.

## Requirements

Create or extend repository methods:

```text
getComparisonFeed(limit)
voteComparison(comparisonId, selectedOptionId)
```

Recommended layers:

```text
features/polls/data
features/polls/domain
features/polls/presentation
```

or create:

```text
features/comparisons/data
features/comparisons/domain
features/comparisons/presentation
```

Choose the option that causes the least disruption.

## Data Requirements

Flutter must parse:

```text
ComparisonFeedResponseDto
ComparisonDto
ComparisonOptionDto
ComparisonVoteResultDto
```

## Network Requirements

- Use existing Dio client.
- Use existing JWT bearer interceptor/token storage.
- Do not create a second authentication mechanism.
- Do not bypass `AuthTokenStorage`.

## Verification Checklist

- [ ] Flutter repository can call `GET /api/comparisons/feed`.
- [ ] Flutter repository can call `POST /api/comparisons/{id}/vote`.
- [ ] Existing auth token is attached to both requests.
- [ ] DTO mapping works for feed response.
- [ ] DTO mapping works for vote result response.
- [ ] API errors are mapped to domain-friendly failures.
- [ ] Existing login screen still works.
- [ ] App builds successfully.

## GATE 6

You may not start Phase 7 until all checklist items are verified.

---

# PHASE 7 — Feed State Management

## Objective

Create the state management for a vertical comparison feed.

## Requirements

Use BLoC or the existing state management pattern already used in the app.

Recommended events:

```text
ComparisonFeedStarted
ComparisonFeedNextPageRequested
ComparisonVoteSubmitted
ComparisonCardDismissed
ComparisonFeedRefreshRequested
```

Recommended states:

```text
ComparisonFeedInitial
ComparisonFeedLoading
ComparisonFeedLoaded
ComparisonFeedVoting
ComparisonFeedVoteSuccess
ComparisonFeedEmpty
ComparisonFeedFailure
```

## Behavior

The feed state should:

1. Load an initial batch of comparisons.
2. Keep a local queue of comparison cards.
3. Submit vote for selected option.
4. Store vote result for the current card.
5. Allow user to move to next card after vote result is shown.
6. Preload more comparisons when the queue becomes low.
7. Show empty state if there are no comparisons left.

## Important Rules

- Do not remove a card before user sees the result.
- Do not allow double-tap duplicate voting.
- Disable option buttons while vote request is in progress.
- If vote succeeds, show result.
- If duplicate vote error occurs, load next card or show a friendly message.
- If network error occurs, allow retry.

## Verification Checklist

- [ ] Initial feed loads from backend.
- [ ] Feed state stores multiple comparison cards.
- [ ] Vote event sends selected option to backend.
- [ ] Buttons are disabled while voting.
- [ ] Vote result is stored and displayed.
- [ ] User cannot vote twice on the same card.
- [ ] Feed preloads more cards when needed.
- [ ] Empty state appears when no cards remain.
- [ ] Network error state can be retried.
- [ ] Existing auth flow is unchanged.

## GATE 7

You may not start Phase 8 until all checklist items are verified.

---

# PHASE 8 — Reels/Shorts Style Vertical Feed UI

## Objective

Build the main mobile UI where the user swipes vertically through comparison cards.

## UI Concept

The screen should feel like short-form content.

One card fills most or all of the screen.

Each card has:

```text
Top area:
- Category pill
- Optional title/question

Center area:
- Two large option panels

Bottom area:
- Vote instruction
- Result after voting
```

## Layout Requirements

Each comparison card should display:

- Category label
- Question/title
- Left option
- Right option
- Optional images
- Clear tap areas
- Vote result after selection

## Interaction Requirements

- Vertical swipe moves to the next card.
- Before voting, the user can tap one of two options.
- After voting, show percentages.
- After result is visible, user can swipe to next card.
- Do not auto-skip immediately after vote.
- A subtle animation should show selected option.

## Flutter UI Suggestions

Possible widgets:

```text
PageView.builder
PageController
AnimatedSwitcher
AnimatedContainer
GestureDetector
BlocBuilder / BlocConsumer
```

## Visual Design Direction

The app should be:

- Bold
- Youthful
- Fast
- Colorful but clean
- Thumb-friendly
- Minimal text
- Highly readable

Use a card style similar to:

```text
Full-screen dark background
Two large rounded option panels
Big text
Vote result bars
Smooth transition
```

## Verification Checklist

- [ ] Feed screen shows one comparison per screen.
- [ ] Vertical swipe works.
- [ ] Two options are clearly tappable.
- [ ] Selected option has visible feedback.
- [ ] Percentages appear after voting.
- [ ] Result is readable.
- [ ] User can swipe to next comparison after result.
- [ ] Empty state is visually clean.
- [ ] Loading state is visually clean.
- [ ] Error state includes retry.
- [ ] UI works on small and large mobile screens.
- [ ] Existing login flow still routes authenticated user to the feed.

## GATE 8

You may not start Phase 9 until all checklist items are verified.

---

# PHASE 9 — Result UI and Vote Percentage Animation

## Objective

Make voting feel satisfying and understandable.

## Requirements

After user votes:

1. Highlight selected option.
2. Show both option percentages.
3. Show total vote count.
4. Animate result bars from 0 to percentage.
5. Show winner visually.
6. Keep result visible until user swipes.

## Result UI Example

```text
Opel          42%
████████░░

Mercedes      58%
███████████░
Total votes: 1,240
```

## Edge Cases

- If totalVotes = 1, selected option should show 100%.
- If both options are close, display both clearly.
- If one option has 0 votes, display 0%.
- Percentages should sum visually to approximately 100%.

## Verification Checklist

- [ ] Selected option is highlighted after vote.
- [ ] Both percentages are shown.
- [ ] Total vote count is shown.
- [ ] Result bars animate.
- [ ] Winner is visually clear.
- [ ] User cannot change vote after result appears.
- [ ] Result remains visible until swipe.
- [ ] Vote result values come from backend response.

## GATE 9

You may not start Phase 10 until all checklist items are verified.

---

# PHASE 10 — Empty, Loading, Error, and No More Comparisons States

## Objective

Handle all non-happy-path states professionally.

## Required States

### Loading

Shown while first feed is loading.

Text example:

```text
Loading comparisons...
```

### Empty / No More Comparisons

Shown when backend returns no feed items.

Text example:

```text
You voted on everything for now.
Come back later for new comparisons.
```

### Error

Shown when network/backend error occurs.

Must include retry button.

### Duplicate Vote

If backend returns `ALREADY_VOTED`, show a friendly message and move to next comparison if possible.

## Verification Checklist

- [ ] Initial loading state exists.
- [ ] Empty state exists.
- [ ] Error state exists with retry.
- [ ] Duplicate vote error is handled gracefully.
- [ ] App does not crash on 401/403.
- [ ] App does not crash on 404 no more comparisons.
- [ ] App does not crash on network timeout.
- [ ] Auth state still handles logout/expired token correctly.

## GATE 10

You may not start Phase 11 until all checklist items are verified.

---

# PHASE 11 — UI/UX Polish Pass

## Objective

Improve the user experience without changing business logic.

## Requirements

Polish:

- Spacing
- Typography
- Option card sizes
- Color contrast
- Tap feedback
- Swipe smoothness
- Loading skeleton
- Vote animation timing
- Result bar readability
- Empty state illustration or icon
- Category pill styling

## Mobile UX Rules

- Primary tap targets should be at least 48dp.
- Text must remain readable on small screens.
- Avoid too much text.
- The screen should be usable with one thumb.
- Vote action must feel instant.
- Animation must not slow down repeated usage.

## Verification Checklist

- [ ] UI is usable on small phones.
- [ ] UI is usable on large phones.
- [ ] Option cards are easy to tap.
- [ ] Text is readable.
- [ ] Vote feedback is instant.
- [ ] Swipe does not feel laggy.
- [ ] Result bars are clear.
- [ ] Dark/light theme behavior is acceptable.
- [ ] No business logic changed during polish.

## GATE 11

You may not start Phase 12 until all checklist items are verified.

---

# PHASE 12 — Backend Tests

## Objective

Add or update backend tests for comparison feed and vote behavior.

## Required Test Coverage

Test:

1. Unauthenticated user cannot access feed.
2. Authenticated user can access feed.
3. Feed excludes already voted comparisons.
4. Feed returns only two-option comparisons.
5. Feed respects limit.
6. Vote endpoint saves vote.
7. Duplicate vote returns conflict.
8. Invalid option returns bad request.
9. Vote result percentages are correct.
10. Existing poll endpoints still work.

## Verification Checklist

- [ ] Feed auth test exists.
- [ ] Feed exclusion test exists.
- [ ] Two-option filter test exists.
- [ ] Limit test exists.
- [ ] Vote success test exists.
- [ ] Duplicate vote test exists.
- [ ] Invalid option test exists.
- [ ] Percentage calculation test exists.
- [ ] Existing tests pass.

## GATE 12

You may not start Phase 13 until all checklist items are verified.

---

# PHASE 13 — Flutter Tests

## Objective

Add or update Flutter tests for comparison feed behavior.

## Required Test Coverage

Test:

1. Comparison model parsing.
2. Feed repository success.
3. Vote repository success.
4. Feed BLoC initial load.
5. Vote success state.
6. Vote error state.
7. Empty state.
8. UI renders two options.
9. UI disables buttons while voting.
10. Result percentages appear after vote.

## Verification Checklist

- [ ] Model parsing tests exist.
- [ ] Repository tests exist.
- [ ] BLoC feed load test exists.
- [ ] BLoC vote success test exists.
- [ ] BLoC error test exists.
- [ ] Widget test renders comparison options.
- [ ] Widget test verifies result display.
- [ ] Flutter tests pass.

## GATE 13

You may not start Phase 14 until all checklist items are verified.

---

# PHASE 14 — Performance and Feed Preloading

## Objective

Ensure the feed feels fast and does not request data too late.

## Requirements

- Load initial batch with `limit=10`.
- When remaining local cards <= 3, request more.
- Do not duplicate cards already in queue.
- Do not request more if request already in progress.
- Do not request more if backend indicates no more items.
- Keep memory usage reasonable.
- Avoid rebuilding the whole feed unnecessarily.

## Verification Checklist

- [ ] Initial feed loads 10 items.
- [ ] More items are requested when queue has 3 or fewer remaining.
- [ ] Duplicate items are not added.
- [ ] Parallel feed requests are prevented.
- [ ] No-more-feed state prevents unnecessary requests.
- [ ] Swipe remains smooth.
- [ ] UI does not visibly freeze during feed loading.

## GATE 14

You may not start Phase 15 until all checklist items are verified.

---

# PHASE 15 — Analytics Events

## Objective

Add lightweight analytics events for product learning.

## Events

Track:

```text
comparison_feed_opened
comparison_card_seen
comparison_vote_submitted
comparison_vote_success
comparison_vote_failed
comparison_result_seen
comparison_card_swiped
comparison_feed_empty
```

## Rules

- Do not log sensitive personal data.
- Do not log Firebase token or JWT.
- Do not log email address.
- Comparison ID is acceptable if needed.
- Category is acceptable.
- Selected option ID is acceptable.

## Verification Checklist

- [ ] Feed opened event is tracked.
- [ ] Card seen event is tracked.
- [ ] Vote submitted event is tracked.
- [ ] Vote success event is tracked.
- [ ] Vote failure event is tracked.
- [ ] Swipe event is tracked.
- [ ] Empty feed event is tracked.
- [ ] No sensitive auth data is logged.

## GATE 15

You may not start Phase 16 until all checklist items are verified.

---

# PHASE 16 — Final Regression Pass

## Objective

Verify the full app end-to-end.

## End-to-End Flow

Test manually:

```text
Start backend
Start mobile app
Login
Open feed
See comparison
Vote left option
See result
Swipe next
Vote right option
See result
Restart app
Login again
Previously voted comparisons should not appear
Continue voting until no comparisons remain
See empty state
```

## Required Commands

Backend:

```bash
docker compose up -d
dotnet test
dotnet run --project src/YouHaveToSay.Api
```

Mobile:

```bash
cd mobile
flutter pub get
flutter test
flutter run
```

## Final Verification Checklist

- [ ] Backend starts.
- [ ] Mobile app starts.
- [ ] Login works.
- [ ] JWT exchange works.
- [ ] Feed loads.
- [ ] Vote works.
- [ ] Result percentages show.
- [ ] Swipe works.
- [ ] Duplicate vote is prevented.
- [ ] No more comparisons state works.
- [ ] Existing poll endpoints still work.
- [ ] Existing tests pass.
- [ ] New backend tests pass.
- [ ] New Flutter tests pass.
- [ ] UI is smooth enough for repeated usage.

## GATE 16

Implementation is complete only when all checklist items pass.

---

# API Summary

## GET Comparison Feed

```http
GET /api/comparisons/feed?limit=10
Authorization: Bearer {token}
```

Response:

```json
{
  "items": [
    {
      "id": "comparison-id",
      "titleTr": "Hangisini seçerdin?",
      "titleEn": "Which one would you choose?",
      "leftOption": {
        "id": "left-option-id",
        "textTr": "Opel",
        "textEn": "Opel",
        "imageUrl": null
      },
      "rightOption": {
        "id": "right-option-id",
        "textTr": "Mercedes",
        "textEn": "Mercedes",
        "imageUrl": null
      },
      "category": "cars",
      "hasVoted": false
    }
  ],
  "hasMore": true
}
```

## POST Vote

```http
POST /api/comparisons/{id}/vote
Authorization: Bearer {token}
Content-Type: application/json
```

Request:

```json
{
  "selectedOptionId": "option-id"
}
```

Response:

```json
{
  "comparisonId": "comparison-id",
  "selectedOptionId": "option-id",
  "totalVotes": 1240,
  "leftOption": {
    "id": "left-option-id",
    "voteCount": 720,
    "percentage": 58.06
  },
  "rightOption": {
    "id": "right-option-id",
    "voteCount": 520,
    "percentage": 41.94
  }
}
```

---

# UI Screen Summary

## Auth Screen

Existing login screen must remain.

## Comparison Feed Screen

Main authenticated screen.

Contains:

- Full-screen vertical feed
- One comparison per page
- Two large options
- Vote result after selection
- Swipe to next card

## Empty Feed Screen

Shown when no more comparisons exist.

## Error Screen

Shown when feed cannot load.

Must include retry.

---

# Recommended File/Folder Direction

Use existing structure if possible.

Recommended mobile structure:

```text
mobile/lib/features/comparisons/
├── data/
│   ├── comparison_dto.dart
│   ├── comparison_repository_impl.dart
│   └── comparison_api.dart
├── domain/
│   ├── comparison.dart
│   ├── comparison_option.dart
│   ├── comparison_vote_result.dart
│   └── comparison_repository.dart
└── presentation/
    ├── bloc/
    │   ├── comparison_feed_bloc.dart
    │   ├── comparison_feed_event.dart
    │   └── comparison_feed_state.dart
    ├── comparison_feed_screen.dart
    ├── comparison_card.dart
    ├── comparison_option_panel.dart
    └── comparison_result_view.dart
```

Recommended backend additions:

```text
src/YouHaveToSay.Application/
├── Comparisons/
│   ├── ComparisonDto.cs
│   ├── ComparisonOptionDto.cs
│   ├── ComparisonFeedResponseDto.cs
│   ├── ComparisonVoteRequest.cs
│   ├── ComparisonVoteResultDto.cs
│   └── IComparisonService.cs

src/YouHaveToSay.Infrastructure/
├── Comparisons/
│   └── ComparisonService.cs

src/YouHaveToSay.Api/
├── Controllers/
│   └── ComparisonsController.cs
```

Do not create this exact structure blindly if the current project already has a cleaner convention. Follow the existing conventions first.

---

# Final Product Definition

When this implementation is complete, the app should work like this:

```text
The user logs in.
The user sees a full-screen comparison.
The user chooses one of two options.
The app submits the vote.
The result percentages appear immediately.
The user swipes to the next comparison.
The user continues voting like watching Reels/Shorts.
Previously voted comparisons never appear again.
```

The final feeling should be:

> Fast, simple, addictive, social, and mobile-first.

