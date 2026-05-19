# YouHaveToSay — Backoffice AI Implementation Guide
## Admin Panel for Comparisons, Polls, Votes, Results and Analytics

---

## MANDATORY OPERATING INSTRUCTIONS FOR CURSOR / AI AGENT

You are an AI implementation agent working on the **YouHaveToSay Backoffice**.

Before writing a single line of code, read this entire document from start to finish. Do not skim. Do not skip sections.

These are your binding operating rules:

1. **You implement exactly ONE phase at a time.**
2. **You do not start Phase N+1 until every checklist item in Phase N is verified.**
3. **You must output a GATE REPORT at the end of every phase.**
4. **If any checklist item fails, you stop, fix it, and re-run the checklist.**
5. **You do not break the existing mobile app.**
6. **You do not break the existing API authentication flow.**
7. **You do not rewrite the existing architecture.**
8. **You do not remove existing poll/comparison/vote logic.**
9. **You do not create speculative or unused placeholder code.**
10. **You keep the backend in ASP.NET Core / Clean Architecture style.**
11. **You build the backoffice frontend with Vue.js + Tailwind CSS.**
12. **You protect all backoffice endpoints with admin authorization.**

Failure to follow these rules will create a broken product. There are no exceptions.

---

# 0. Existing Application Context

The existing product is:

```text
YouHaveToSay
```

It is a mobile voting application where users authenticate, see comparisons in a Reels/Shorts-style feed, vote once, and see results.

Existing technology stack:

| Area | Technology |
|---|---|
| Backend | ASP.NET Core 9 |
| ORM | EF Core |
| Database | PostgreSQL |
| Mobile | Flutter |
| Auth | Firebase + API JWT |
| State Management | BLoC on mobile |
| Backoffice Frontend | Vue.js + Tailwind CSS |
| Backoffice Backend | Existing ASP.NET Core API extended with admin endpoints |

Existing backend structure:

```text
src/
├── YouHaveToSay.Domain
├── YouHaveToSay.Application
├── YouHaveToSay.Infrastructure
└── YouHaveToSay.Api
```

Existing product entities:

```text
User
Poll
PollOption
Vote
```

Product language for the app:

```text
Poll = Comparison
PollOption = Comparison Option
Vote = Vote
```

The backoffice must respect this model. It can display the product term **Comparison**, while backend may still internally use `Poll`.

---

# 1. Backoffice Product Goal

The goal is to build an admin panel where authorized users can:

1. Log in to backoffice.
2. View dashboard summary.
3. Create new comparisons / polls.
4. Edit existing comparisons / polls.
5. Activate or deactivate comparisons.
6. View all comparisons.
7. View vote counts.
8. View vote percentages.
9. View comparison detail results.
10. Filter comparisons by status, category, date and search text.
11. See most voted comparisons.
12. See latest created comparisons.
13. Prepare the system for future moderation and reporting.

The backoffice is not for public users.  
It is for admins / internal operators.

---

# 2. Core Backoffice UX Principle

The backoffice must be:

```text
Clean
Fast
Simple
Data-focused
Admin-friendly
Mobile-responsive enough, but desktop-first
```

The main use case is content management and result monitoring.

The admin must be able to answer these questions quickly:

```text
How many comparisons exist?
Which comparisons are active?
Which comparisons got the most votes?
What are the vote percentages?
Which comparisons should be edited or deactivated?
Are there any comparisons with very low engagement?
```

---

# 3. Protected Existing Systems

The following existing systems must not be broken:

| Existing System | Rule |
|---|---|
| Mobile app login | Must keep working |
| Firebase auth | Must keep working |
| API JWT | Must keep working |
| Comparison feed endpoint | Must keep working |
| Comparison vote endpoint | Must keep working |
| One-vote-per-comparison rule | Must remain enforced |
| Existing Poll / PollOption / Vote tables | Must not be destructively changed |
| Existing mobile DTOs | Must remain compatible |
| Existing tests | Must continue passing or be intentionally updated |
| PostgreSQL database | Must remain source of truth |

Backoffice features must be added without damaging the mobile experience.

---

# 4. Backoffice Access and Security Rules

Backoffice must never be public.

All admin endpoints must require:

```text
Authentication + Admin authorization
```

Minimum accepted admin approach for MVP:

```text
Admin users are identified by email allowlist in configuration.
```

Example configuration:

```json
{
  "Backoffice": {
    "AdminEmails": [
      "admin@youhavetosay.com",
      "omer@example.com"
    ]
  }
}
```

Recommended future approach:

```text
Add role/claim-based authorization.
```

But for MVP, email allowlist is acceptable if implemented safely.

## Mandatory Rules

1. Public users must not access backoffice endpoints.
2. A valid JWT is required.
3. The authenticated user's email must be in the admin allowlist.
4. Unauthorized users receive `403 Forbidden`.
5. Unauthenticated users receive `401 Unauthorized`.
6. Admin check must happen on backend, not only in Vue UI.
7. Vue route guard is helpful but not sufficient.

---

# 5. Backoffice Main Modules

The backoffice will include these modules:

```text
Dashboard
Comparisons List
Create Comparison
Edit Comparison
Comparison Detail / Results
Categories
Users / Voters Summary
Settings
```

For MVP, implement in this order:

```text
1. Admin auth protection
2. Dashboard
3. Comparisons list
4. Create comparison
5. Edit comparison
6. Results detail
7. Filters/search
8. Categories
9. Users summary
10. Final polish/tests
```

---

# 6. Mandatory Phase Execution Process

For each phase, follow this exact sequence:

```text
STEP 1 — Read the phase completely.
STEP 2 — Identify files that must be touched.
STEP 3 — Implement only this phase.
STEP 4 — Verify every checklist item.
STEP 5 — Output GATE REPORT.
STEP 6 — Stop.
STEP 7 — Do not start the next phase until approved.
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

If one item fails:

```text
=== GATE [N] REPORT ===
[✗] Item X — Failure reason.

GATE [N] FAILED.
STOPPING IMPLEMENTATION UNTIL THIS IS FIXED.
```

---

# 7. Architecture Rules

## Rule A — Backend Clean Architecture Must Stay

Backend dependency direction must remain:

```text
YouHaveToSay.Api
 → YouHaveToSay.Infrastructure
   → YouHaveToSay.Application
     → YouHaveToSay.Domain
```

Do not put EF queries in controllers.  
Do not put business logic in controllers.

## Rule B — Backoffice API Must Be Separate

Backoffice endpoints must be clearly separated from public/mobile endpoints.

Recommended route prefix:

```text
/api/backoffice
```

Examples:

```text
GET    /api/backoffice/dashboard
GET    /api/backoffice/comparisons
POST   /api/backoffice/comparisons
GET    /api/backoffice/comparisons/{id}
PUT    /api/backoffice/comparisons/{id}
PATCH  /api/backoffice/comparisons/{id}/status
GET    /api/backoffice/comparisons/{id}/results
```

## Rule C — Vue Frontend Must Be Separate

Create a separate frontend app/folder for backoffice.

Recommended structure:

```text
backoffice/
├── package.json
├── vite.config.ts
├── tailwind.config.js
├── index.html
└── src/
    ├── main.ts
    ├── App.vue
    ├── router/
    ├── layouts/
    ├── pages/
    ├── components/
    ├── services/
    ├── stores/
    └── styles/
```

Do not mix Vue backoffice files into the Flutter mobile folder.

## Rule D — Tailwind First

Use Tailwind CSS for layout, spacing, colors and responsive design.

Avoid large custom CSS files unless required.

## Rule E — API Result Values Come From Backend

Vote counts and percentages must come from backend.

Vue must not calculate official result percentages from incomplete local data.

## Rule F — Admin Actions Must Be Auditable

Whenever possible, store:

```text
CreatedAt
UpdatedAt
CreatedBy
UpdatedBy
```

If current schema does not support all of these yet, implement at least `CreatedAt` and `IsActive`, then prepare extension points for audit fields.

## Rule G — Do Not Start With Fancy UI

Build working admin flow first.

Order:

```text
Security
Data
CRUD
Results
UX polish
```

---

# PHASE 1 — Inspect Existing System and Define Backoffice Extension Points

## Objective

Understand current backend and frontend structure before writing backoffice code.

## What To Inspect

Backend:

```text
src/YouHaveToSay.Domain
src/YouHaveToSay.Application
src/YouHaveToSay.Infrastructure
src/YouHaveToSay.Api
```

Existing entities:

```text
User
Poll
PollOption
Vote
```

Existing services:

```text
AuthService
PollService
JwtTokenService
CurrentUserService
```

Existing controllers:

```text
AuthController
PollsController
ComparisonsController if already exists
```

Existing mobile/frontend:

```text
mobile/
```

## Implementation Requirements

- Do not change production behavior.
- Do not create endpoints.
- Do not create Vue app yet.
- Only inspect and document safe extension points.

## Expected Output

At the end of this phase, produce a short implementation note:

```text
Backend extension points:
- Admin authorization service/filter
- Backoffice DTOs
- Backoffice service
- Backoffice controller
- Poll/PollOption update paths
- Vote aggregation queries

Frontend extension points:
- New backoffice Vue app
- Auth token storage strategy
- API client service
- Vue router
```

## Verification Checklist

- [ ] Existing backend architecture is understood.
- [ ] Existing Poll/PollOption/Vote model is understood.
- [ ] Existing JWT auth behavior is understood.
- [ ] Existing comparison/feed/vote behavior is understood.
- [ ] Safe backend extension points are identified.
- [ ] Safe Vue backoffice folder location is identified.
- [ ] No production code was changed.

## GATE 1

You may not start Phase 2 until all checklist items are verified.

---

# PHASE 2 — Admin Authorization Foundation

## Objective

Add backend admin authorization for all future backoffice endpoints.

## Backend Requirements

Create an admin authorization mechanism.

MVP approach:

```text
Authenticated JWT user email must exist in Backoffice:AdminEmails config.
```

Recommended components:

```text
IBackofficeAuthorizationService
BackofficeAuthorizationService
BackofficeAdminOnly attribute or policy
BackofficeOptions
```

Recommended configuration:

```json
{
  "Backoffice": {
    "AdminEmails": [
      "admin@example.com"
    ]
  }
}
```

## Behavior

- If no JWT: return 401.
- If JWT exists but email is not admin: return 403.
- If JWT exists and email is admin: allow request.

## Implementation Notes

- Do not create fake auth.
- Use existing JWT authentication.
- Do not bypass existing auth middleware.
- Do not rely only on Vue route guards.

## Verification Checklist

- [ ] Backoffice admin email configuration exists.
- [ ] Admin authorization service or policy exists.
- [ ] Backend can identify authenticated user's email.
- [ ] Unauthenticated requests return 401.
- [ ] Authenticated non-admin requests return 403.
- [ ] Authenticated admin requests are allowed.
- [ ] Existing mobile endpoints are not affected.
- [ ] Existing login flow still works.

## GATE 2

You may not start Phase 3 until all checklist items are verified.

---

# PHASE 3 — Backoffice DTOs and Service Contracts

## Objective

Define DTOs and service interfaces for backoffice comparison management.

## Backend Application Layer Requirements

Create DTOs:

```text
BackofficeComparisonListItemDto
BackofficeComparisonDetailDto
BackofficeComparisonOptionDto
CreateComparisonRequest
UpdateComparisonRequest
UpdateComparisonStatusRequest
ComparisonResultDto
ComparisonOptionResultDto
BackofficeDashboardDto
BackofficePagedResponse<T>
```

## DTO Suggestions

### BackofficeComparisonListItemDto

```json
{
  "id": "uuid",
  "titleTr": "Hangisini seçerdin?",
  "titleEn": "Which one would you choose?",
  "category": "cars",
  "isActive": true,
  "createdAt": "2026-05-20T10:00:00Z",
  "optionCount": 2,
  "totalVotes": 1240,
  "leftOptionText": "Opel",
  "rightOptionText": "Mercedes"
}
```

### BackofficeComparisonDetailDto

```json
{
  "id": "uuid",
  "titleTr": "Hangisini seçerdin?",
  "titleEn": "Which one would you choose?",
  "category": "cars",
  "isActive": true,
  "createdAt": "2026-05-20T10:00:00Z",
  "options": [
    {
      "id": "uuid",
      "textTr": "Opel",
      "textEn": "Opel",
      "imageUrl": null,
      "displayOrder": 1
    },
    {
      "id": "uuid",
      "textTr": "Mercedes",
      "textEn": "Mercedes",
      "imageUrl": null,
      "displayOrder": 2
    }
  ]
}
```

### CreateComparisonRequest

```json
{
  "titleTr": "Hangisini seçerdin?",
  "titleEn": "Which one would you choose?",
  "category": "cars",
  "isActive": true,
  "leftOption": {
    "textTr": "Opel",
    "textEn": "Opel",
    "imageUrl": null
  },
  "rightOption": {
    "textTr": "Mercedes",
    "textEn": "Mercedes",
    "imageUrl": null
  }
}
```

### ComparisonResultDto

```json
{
  "comparisonId": "uuid",
  "titleTr": "Hangisini seçerdin?",
  "titleEn": "Which one would you choose?",
  "totalVotes": 1240,
  "options": [
    {
      "optionId": "uuid",
      "textTr": "Opel",
      "textEn": "Opel",
      "voteCount": 720,
      "percentage": 58.06
    },
    {
      "optionId": "uuid",
      "textTr": "Mercedes",
      "textEn": "Mercedes",
      "voteCount": 520,
      "percentage": 41.94
    }
  ]
}
```

## Service Contract

Create:

```text
IBackofficeComparisonService
```

Recommended methods:

```csharp
Task<BackofficeDashboardDto> GetDashboardAsync(CancellationToken cancellationToken);
Task<BackofficePagedResponse<BackofficeComparisonListItemDto>> GetComparisonsAsync(BackofficeComparisonQuery query, CancellationToken cancellationToken);
Task<BackofficeComparisonDetailDto> GetComparisonDetailAsync(Guid id, CancellationToken cancellationToken);
Task<Guid> CreateComparisonAsync(CreateComparisonRequest request, CancellationToken cancellationToken);
Task UpdateComparisonAsync(Guid id, UpdateComparisonRequest request, CancellationToken cancellationToken);
Task UpdateComparisonStatusAsync(Guid id, UpdateComparisonStatusRequest request, CancellationToken cancellationToken);
Task<ComparisonResultDto> GetComparisonResultsAsync(Guid id, CancellationToken cancellationToken);
```

## Verification Checklist

- [ ] Backoffice DTOs exist in Application layer.
- [ ] DTOs do not expose unnecessary internal database details.
- [ ] Create request supports exactly two options.
- [ ] Update request supports exactly two options.
- [ ] Result DTO supports vote count and percentage.
- [ ] Paged response DTO exists.
- [ ] Service interface exists.
- [ ] No controller logic was implemented yet.
- [ ] Existing mobile DTOs are unchanged.

## GATE 3

You may not start Phase 4 until all checklist items are verified.

---

# PHASE 4 — Backoffice Service Implementation

## Objective

Implement backoffice comparison management logic in Infrastructure layer.

## Requirements

Create:

```text
BackofficeComparisonService
```

This service must implement `IBackofficeComparisonService`.

## Required Behaviors

### Dashboard

Return:

```text
Total comparisons
Active comparisons
Inactive comparisons
Total votes
Comparisons created this week
Most voted comparisons
Latest comparisons
```

### List Comparisons

Support:

```text
Pagination
Search by title / option text
Filter by category
Filter by active/inactive
Sort by created date
Sort by total votes
```

### Create Comparison

Rules:

1. Title TR is required.
2. Category is required.
3. Left option text TR is required.
4. Right option text TR is required.
5. Exactly two options must be created.
6. Both options must belong to the created comparison.
7. Comparison can be created active or inactive.

### Update Comparison

Rules:

1. Existing comparison must exist.
2. Title/category can be updated.
3. Option texts can be updated.
4. Image URLs can be updated.
5. Must remain exactly two options.
6. Existing votes must not be deleted during update.

### Status Update

Rules:

```text
Active → Inactive
Inactive → Active
```

No vote records should be deleted.

### Results

Rules:

1. Count votes for each option.
2. Calculate total votes.
3. Calculate percentages.
4. Return 0% if no votes exist.
5. Percentages should be rounded to 2 decimals.

## Verification Checklist

- [ ] Dashboard aggregation works.
- [ ] Comparison list supports pagination.
- [ ] Comparison list supports search.
- [ ] Comparison list supports category filter.
- [ ] Comparison list supports status filter.
- [ ] Create comparison creates exactly two options.
- [ ] Update comparison keeps existing votes.
- [ ] Status update does not delete votes.
- [ ] Results calculate counts correctly.
- [ ] Results calculate percentages correctly.
- [ ] Existing mobile feed and vote behavior are not broken.

## GATE 4

You may not start Phase 5 until all checklist items are verified.

---

# PHASE 5 — Backoffice API Controller

## Objective

Expose backoffice endpoints from ASP.NET Core API.

## Required Controller

Create:

```text
BackofficeComparisonsController
```

Recommended route:

```text
/api/backoffice
```

## Endpoints

```text
GET    /api/backoffice/dashboard
GET    /api/backoffice/comparisons
POST   /api/backoffice/comparisons
GET    /api/backoffice/comparisons/{id}
PUT    /api/backoffice/comparisons/{id}
PATCH  /api/backoffice/comparisons/{id}/status
GET    /api/backoffice/comparisons/{id}/results
```

## Query Parameters for List

```text
page
pageSize
search
category
isActive
sortBy
sortDirection
```

Defaults:

```text
page = 1
pageSize = 20
sortBy = createdAt
sortDirection = desc
```

Maximum:

```text
pageSize = 100
```

## Security

Every endpoint must require admin authorization.

No endpoint under `/api/backoffice` may be public.

## Verification Checklist

- [ ] Dashboard endpoint exists.
- [ ] Comparison list endpoint exists.
- [ ] Create comparison endpoint exists.
- [ ] Detail endpoint exists.
- [ ] Update endpoint exists.
- [ ] Status update endpoint exists.
- [ ] Results endpoint exists.
- [ ] All endpoints require authentication.
- [ ] All endpoints require admin authorization.
- [ ] Non-admin users receive 403.
- [ ] Existing public/mobile endpoints still work.

## GATE 5

You may not start Phase 6 until all checklist items are verified.

---

# PHASE 6 — Backend Validation and Error Handling

## Objective

Make backoffice API safe, predictable and admin-friendly.

## Required Validation

Create/update validation for:

### CreateComparisonRequest

- `titleTr` required
- `category` required
- `leftOption.textTr` required
- `rightOption.textTr` required
- left and right option text must not be identical in the same language if both are provided
- imageUrl must be valid URL if provided
- category length should be reasonable

### UpdateComparisonRequest

- same rules as create
- comparison must exist

### Status Update

- comparison must exist
- `isActive` must be explicit boolean

## Error Format

Use existing global exception middleware style.

Recommended error shape:

```json
{
  "code": "VALIDATION_ERROR",
  "message": "Title is required."
}
```

## Verification Checklist

- [ ] Create validation rejects missing title.
- [ ] Create validation rejects missing category.
- [ ] Create validation rejects missing option text.
- [ ] Create validation rejects identical options.
- [ ] Update validation rejects invalid comparison id.
- [ ] Invalid image URL is rejected if validation exists.
- [ ] API returns clear error messages.
- [ ] Existing global exception middleware still works.

## GATE 6

You may not start Phase 7 until all checklist items are verified.

---

# PHASE 7 — Vue Backoffice Project Setup

## Objective

Create the Vue.js + Tailwind CSS backoffice frontend.

## Requirements

Create a new folder:

```text
backoffice/
```

Use:

```text
Vue 3
Vite
TypeScript
Tailwind CSS
Vue Router
Pinia or simple composables for state
Axios or Fetch wrapper
```

## Recommended Structure

```text
backoffice/
├── package.json
├── vite.config.ts
├── tailwind.config.js
├── postcss.config.js
├── index.html
└── src/
    ├── main.ts
    ├── App.vue
    ├── router/
    │   └── index.ts
    ├── layouts/
    │   └── AdminLayout.vue
    ├── pages/
    │   ├── LoginPage.vue
    │   ├── DashboardPage.vue
    │   ├── ComparisonsListPage.vue
    │   ├── ComparisonCreatePage.vue
    │   ├── ComparisonEditPage.vue
    │   └── ComparisonResultsPage.vue
    ├── components/
    │   ├── AppSidebar.vue
    │   ├── AppTopbar.vue
    │   ├── StatCard.vue
    │   ├── DataTable.vue
    │   ├── EmptyState.vue
    │   ├── LoadingState.vue
    │   └── ErrorState.vue
    ├── services/
    │   ├── apiClient.ts
    │   └── backofficeApi.ts
    ├── stores/
    │   └── authStore.ts
    └── styles/
        └── index.css
```

## Visual Direction

Use Tailwind for:

```text
Sidebar
Topbar
Cards
Tables
Forms
Badges
Buttons
Modals
Responsive layout
```

Style should be:

```text
Clean dashboard
Light background
White cards
Rounded corners
Subtle shadows
Readable tables
Clear status badges
```

## Verification Checklist

- [ ] `backoffice/` folder exists.
- [ ] Vue 3 project runs with Vite.
- [ ] Tailwind CSS is configured and working.
- [ ] Vue Router is installed and configured.
- [ ] Basic AdminLayout exists.
- [ ] Sidebar and topbar exist.
- [ ] Dashboard route exists.
- [ ] Comparisons list route exists.
- [ ] Project builds successfully.
- [ ] Mobile Flutter folder is untouched.

## GATE 7

You may not start Phase 8 until all checklist items are verified.

---

# PHASE 8 — Backoffice Authentication UI

## Objective

Allow admin users to access the backoffice securely.

## MVP Auth Options

Preferred:

```text
Use existing Firebase login flow if practical in Vue.
```

Alternative for MVP:

```text
Email/password or dev token only if backend supports it safely.
```

Important:

```text
Do not create an insecure fake admin login for production.
```

## Required Behavior

1. Admin opens `/login`.
2. Admin signs in.
3. Frontend obtains token.
4. Frontend calls backend admin-protected endpoint.
5. If authorized, user enters dashboard.
6. If unauthorized, show clear message.
7. Token is stored safely.
8. Logout clears token.

## Route Guard

Protected routes:

```text
/dashboard
/comparisons
/comparisons/create
/comparisons/:id/edit
/comparisons/:id/results
```

If no token exists, redirect to `/login`.

If backend returns 401/403, clear session and show message.

## Verification Checklist

- [ ] Login page exists.
- [ ] Token is stored after login.
- [ ] API client attaches token to requests.
- [ ] Protected Vue routes require token.
- [ ] 401 response redirects to login.
- [ ] 403 response shows unauthorized message.
- [ ] Logout clears token.
- [ ] Backend admin authorization is still enforced.

## GATE 8

You may not start Phase 9 until all checklist items are verified.

---

# PHASE 9 — Backoffice API Client

## Objective

Connect Vue backoffice to backend endpoints.

## Required API Client Methods

Create:

```typescript
getDashboard()
getComparisons(query)
getComparisonDetail(id)
createComparison(request)
updateComparison(id, request)
updateComparisonStatus(id, isActive)
getComparisonResults(id)
```

## Requirements

- Use one shared API client.
- Attach Bearer token automatically.
- Handle 401 globally.
- Handle 403 globally.
- Map backend errors to readable messages.
- Do not duplicate API base URL in many files.
- Use environment variable for API base URL.

Example env:

```text
VITE_API_BASE_URL=http://localhost:5106
```

## Verification Checklist

- [ ] Shared API client exists.
- [ ] Bearer token is attached.
- [ ] Dashboard method exists.
- [ ] Comparison list method exists.
- [ ] Create method exists.
- [ ] Update method exists.
- [ ] Status update method exists.
- [ ] Results method exists.
- [ ] 401/403 are handled globally.
- [ ] API base URL comes from env.

## GATE 9

You may not start Phase 10 until all checklist items are verified.

---

# PHASE 10 — Dashboard Page

## Objective

Build the first useful admin screen.

## Dashboard Must Show

Stat cards:

```text
Total comparisons
Active comparisons
Inactive comparisons
Total votes
Created this week
Average votes per comparison
```

Sections:

```text
Most voted comparisons
Latest comparisons
```

## UI Requirements

Use Tailwind cards.

Each stat card should include:

```text
Label
Value
Optional short helper text
Icon or visual marker
```

Most voted table columns:

```text
Comparison
Category
Total Votes
Status
View Results button
```

Latest table columns:

```text
Comparison
Category
Created At
Status
Edit button
```

## Verification Checklist

- [ ] Dashboard page calls `getDashboard()`.
- [ ] Stat cards render correctly.
- [ ] Most voted comparisons render.
- [ ] Latest comparisons render.
- [ ] Loading state exists.
- [ ] Error state exists.
- [ ] View results navigation works.
- [ ] Edit navigation works.
- [ ] UI is clean and readable.

## GATE 10

You may not start Phase 11 until all checklist items are verified.

---

# PHASE 11 — Comparisons List Page

## Objective

Build the main management table for all comparisons.

## Required Features

Table columns:

```text
Title
Left Option
Right Option
Category
Status
Total Votes
Created At
Actions
```

Actions:

```text
View Results
Edit
Activate / Deactivate
```

Filters:

```text
Search
Category
Status
Date range if practical
Sort by created date
Sort by total votes
```

Pagination:

```text
Page
Page size
Total count
Next / Previous
```

## UI Rules

- Active comparisons show green badge.
- Inactive comparisons show gray/red badge.
- Long titles should truncate cleanly.
- Actions should be easy to find.
- Empty state should be friendly.

## Verification Checklist

- [ ] Comparisons list loads from API.
- [ ] Pagination works.
- [ ] Search works.
- [ ] Category filter works.
- [ ] Status filter works.
- [ ] Sort works.
- [ ] Activate/deactivate works.
- [ ] Edit navigation works.
- [ ] Results navigation works.
- [ ] Empty state exists.
- [ ] Loading/error states exist.

## GATE 11

You may not start Phase 12 until all checklist items are verified.

---

# PHASE 12 — Create Comparison Page

## Objective

Allow admin to create a new comparison with two options.

## Form Fields

```text
Title TR
Title EN
Category
Is Active
Left Option Text TR
Left Option Text EN
Left Option Image URL
Right Option Text TR
Right Option Text EN
Right Option Image URL
```

## Form Validation

Frontend validation:

- Title TR required.
- Category required.
- Left Option Text TR required.
- Right Option Text TR required.
- Left and right options should not be identical.
- Image URL must look valid if provided.

Backend validation remains source of truth.

## UX Requirements

- Show live preview card.
- Save button disabled while submitting.
- Show success message after save.
- After successful save, navigate to edit or list page.
- Show backend validation errors clearly.

## Verification Checklist

- [ ] Create form renders.
- [ ] Required field validation works.
- [ ] Identical option validation works.
- [ ] Live preview updates.
- [ ] Submit calls create API.
- [ ] Loading state during submit exists.
- [ ] Success message appears.
- [ ] Backend validation errors display.
- [ ] Created comparison appears in list.
- [ ] Mobile feed can receive active created comparison.

## GATE 12

You may not start Phase 13 until all checklist items are verified.

---

# PHASE 13 — Edit Comparison Page

## Objective

Allow admin to edit an existing comparison.

## Requirements

1. Load comparison detail by ID.
2. Populate form fields.
3. Allow editing title, category, status and option texts/images.
4. Do not delete existing votes.
5. Save updates through API.
6. Show success/error messages.
7. Allow navigation to results page.

## Important Rule

Editing option text must not delete votes.

Votes are connected to option IDs, so preserve option IDs during update.

## Verification Checklist

- [ ] Edit page loads comparison detail.
- [ ] Form is populated correctly.
- [ ] Option IDs are preserved.
- [ ] Updating title works.
- [ ] Updating category works.
- [ ] Updating option text works.
- [ ] Updating image URL works.
- [ ] Existing votes remain after update.
- [ ] Success/error messages work.
- [ ] Results page navigation works.

## GATE 13

You may not start Phase 14 until all checklist items are verified.

---

# PHASE 14 — Comparison Results Page

## Objective

Allow admin to view vote results for a comparison.

## Required Display

Top section:

```text
Comparison title
Category
Status
Created date
Total votes
```

Result section:

```text
Left option vote count
Left option percentage
Right option vote count
Right option percentage
Winner badge
```

Visuals:

```text
Horizontal percentage bars
Vote count numbers
Percentage labels
```

Optional:

```text
Simple chart
```

Use CSS/Tailwind bars first. Do not add a heavy chart library unless necessary.

## Edge Cases

- No votes: show both options as 0%.
- Tie: show tie state.
- One option has 100%: bar should display correctly.

## Verification Checklist

- [ ] Results page loads by ID.
- [ ] Total votes display.
- [ ] Vote counts display.
- [ ] Percentages display.
- [ ] Winner is visually clear.
- [ ] Tie state works.
- [ ] No-vote state works.
- [ ] Bars render correctly.
- [ ] Values come from backend, not local calculation.

## GATE 14

You may not start Phase 15 until all checklist items are verified.

---

# PHASE 15 — Categories Management

## Objective

Make category usage cleaner for admins.

## MVP Option

If there is no `Category` table yet, categories may remain string values on comparison records.

Build category helper UI first:

```text
Category dropdown based on existing categories
Option to type a new category
```

## Future Option

A dedicated `Category` entity/table can be added later.

## Requirements

- Create page should suggest existing categories.
- Edit page should suggest existing categories.
- List page should filter by category.
- Dashboard may show top categories by vote count.

## Verification Checklist

- [ ] Existing categories can be fetched or derived.
- [ ] Category dropdown appears on create page.
- [ ] Category dropdown appears on edit page.
- [ ] Admin can type a new category if needed.
- [ ] List category filter works.
- [ ] No existing comparison loses category data.

## GATE 15

You may not start Phase 16 until all checklist items are verified.

---

# PHASE 16 — Users / Voters Summary Page

## Objective

Give admins a high-level view of user and voting activity.

## Required Metrics

```text
Total users
Total voters
Total votes
Average votes per user
Most active voters count
New users this week
```

Do not expose sensitive personal data unnecessarily.

## Optional Table

If shown, keep it minimal:

```text
User email
Total votes
Created date
Last vote date
```

## Privacy Rules

- Do not show Firebase tokens.
- Do not show JWT.
- Do not show sensitive auth metadata.
- Email can be shown only to admin users.
- Avoid unnecessary personal details.

## Verification Checklist

- [ ] Users summary endpoint exists.
- [ ] Page displays user/vote metrics.
- [ ] No sensitive tokens are exposed.
- [ ] Admin authorization protects the endpoint.
- [ ] Page handles empty data.

## GATE 16

You may not start Phase 17 until all checklist items are verified.

---

# PHASE 17 — Backoffice Tests

## Objective

Add backend and frontend tests for backoffice.

## Backend Tests

Required:

1. Non-authenticated user cannot access backoffice endpoints.
2. Non-admin authenticated user receives 403.
3. Admin can access dashboard.
4. Admin can create comparison.
5. Admin can update comparison.
6. Admin can activate/deactivate comparison.
7. Admin can view results.
8. Results percentages are correct.
9. Existing mobile endpoints still work.

## Vue Tests

If test setup exists or is added:

1. Dashboard renders stat cards.
2. List renders comparison rows.
3. Create form validates required fields.
4. Edit form loads data.
5. Results page shows percentages.
6. 401/403 handling works.

## Verification Checklist

- [ ] Backend authorization tests exist.
- [ ] Backend CRUD tests exist.
- [ ] Backend result tests exist.
- [ ] Existing backend tests pass.
- [ ] Vue critical UI tests exist if test setup is available.
- [ ] No mobile tests are broken.

## GATE 17

You may not start Phase 18 until all checklist items are verified.

---

# PHASE 18 — UI/UX Polish and Responsive Pass

## Objective

Make the backoffice feel professional and usable.

## Polish Checklist

- Sidebar spacing
- Topbar spacing
- Table readability
- Button consistency
- Status badges
- Form spacing
- Error messages
- Empty states
- Loading skeletons
- Mobile/tablet responsiveness
- Dark mode only if project already supports it; otherwise do not add it now

## Verification Checklist

- [ ] Dashboard looks clean.
- [ ] Tables are readable.
- [ ] Forms are easy to use.
- [ ] Buttons are consistent.
- [ ] Loading states are polished.
- [ ] Empty states are polished.
- [ ] Error messages are understandable.
- [ ] Layout works on desktop.
- [ ] Layout is usable on tablet.
- [ ] No business logic changed during polish.

## GATE 18

You may not start Phase 19 until all checklist items are verified.

---

# PHASE 19 — Final Regression Pass

## Objective

Verify the complete system end-to-end.

## Backend Commands

```bash
docker compose up -d
dotnet test
dotnet run --project src/YouHaveToSay.Api
```

## Backoffice Commands

```bash
cd backoffice
npm install
npm run dev
npm run build
```

## Mobile Commands

```bash
cd mobile
flutter pub get
flutter test
flutter run
```

## Manual End-to-End Test

```text
1. Start database.
2. Start API.
3. Start backoffice.
4. Login as admin.
5. Open dashboard.
6. Create a new active comparison.
7. Confirm it appears in comparison list.
8. Open mobile app.
9. Login as normal user.
10. Confirm new comparison appears in feed.
11. Vote on the comparison.
12. Return to backoffice.
13. Open comparison results.
14. Confirm vote count and percentages updated.
15. Deactivate the comparison.
16. Confirm it no longer appears in mobile feed.
17. Existing voted records remain visible in results.
```

## Final Verification Checklist

- [ ] Backend starts.
- [ ] Backoffice starts.
- [ ] Mobile app starts.
- [ ] Admin login works.
- [ ] Non-admin access is blocked.
- [ ] Dashboard works.
- [ ] Comparison list works.
- [ ] Create comparison works.
- [ ] Edit comparison works.
- [ ] Activate/deactivate works.
- [ ] Results page works.
- [ ] New active comparison appears in mobile feed.
- [ ] Deactivated comparison does not appear in mobile feed.
- [ ] Vote results update correctly.
- [ ] Existing mobile login still works.
- [ ] Existing mobile voting still works.
- [ ] Backend tests pass.
- [ ] Backoffice build passes.
- [ ] Flutter tests pass.

## GATE 19

Implementation is complete only when all checklist items pass.

---

# Backoffice API Summary

## Dashboard

```http
GET /api/backoffice/dashboard
Authorization: Bearer {token}
```

## List Comparisons

```http
GET /api/backoffice/comparisons?page=1&pageSize=20&search=&category=&isActive=true&sortBy=createdAt&sortDirection=desc
Authorization: Bearer {token}
```

## Create Comparison

```http
POST /api/backoffice/comparisons
Authorization: Bearer {token}
Content-Type: application/json
```

```json
{
  "titleTr": "Hangisini seçerdin?",
  "titleEn": "Which one would you choose?",
  "category": "cars",
  "isActive": true,
  "leftOption": {
    "textTr": "Opel",
    "textEn": "Opel",
    "imageUrl": null
  },
  "rightOption": {
    "textTr": "Mercedes",
    "textEn": "Mercedes",
    "imageUrl": null
  }
}
```

## Get Detail

```http
GET /api/backoffice/comparisons/{id}
Authorization: Bearer {token}
```

## Update Comparison

```http
PUT /api/backoffice/comparisons/{id}
Authorization: Bearer {token}
Content-Type: application/json
```

## Activate / Deactivate

```http
PATCH /api/backoffice/comparisons/{id}/status
Authorization: Bearer {token}
Content-Type: application/json
```

```json
{
  "isActive": false
}
```

## Get Results

```http
GET /api/backoffice/comparisons/{id}/results
Authorization: Bearer {token}
```

Response:

```json
{
  "comparisonId": "uuid",
  "titleTr": "Hangisini seçerdin?",
  "titleEn": "Which one would you choose?",
  "totalVotes": 1240,
  "options": [
    {
      "optionId": "uuid",
      "textTr": "Opel",
      "textEn": "Opel",
      "voteCount": 720,
      "percentage": 58.06
    },
    {
      "optionId": "uuid",
      "textTr": "Mercedes",
      "textEn": "Mercedes",
      "voteCount": 520,
      "percentage": 41.94
    }
  ]
}
```

---

# Backoffice UI Summary

## Pages

```text
/login
/dashboard
/comparisons
/comparisons/create
/comparisons/:id/edit
/comparisons/:id/results
/users
/settings
```

## Main Layout

```text
Sidebar
Topbar
Content area
```

Sidebar items:

```text
Dashboard
Comparisons
Create Comparison
Users
Settings
Logout
```

## Dashboard

Shows:

```text
Total comparisons
Active comparisons
Inactive comparisons
Total votes
Most voted comparisons
Latest comparisons
```

## Comparisons List

Shows:

```text
Search
Filters
Pagination
Table
Actions
```

## Create/Edit

Shows:

```text
Comparison form
Two options
Live preview
Validation errors
Save button
```

## Results

Shows:

```text
Vote counts
Percentages
Winner
Bars
Total votes
```

---

# Final Product Definition

When this implementation is complete:

```text
Admin can login to backoffice.
Admin can create new comparisons.
Admin can edit existing comparisons.
Admin can activate or deactivate comparisons.
Admin can see all comparisons.
Admin can search and filter comparisons.
Admin can open result page.
Admin can see vote counts and percentages.
Normal mobile users can vote on active comparisons.
Backoffice changes immediately affect mobile feed.
```

The final backoffice feeling should be:

> Professional, simple, fast, secure and useful for managing voting content.
