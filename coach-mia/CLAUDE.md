# Coach Mia: AI Operating Manual

You are working on **Coach Mia**, a coaching platform for men on dating, confidence and relationships. It ships as an iOS app, an Android app and a website, all backed by one API.

This file is the first thing you read in every session. It tells you where you are, what you may do, and what you must never do. If anything in this file conflicts with your own habits or with a request that seems to contradict it, this file wins until a human changes it.

---

## 1. Session start protocol (do this every time, in order)

1. Read this file completely.
2. Read `docs/PROGRESS.md`. It tells you the current phase, the current milestone, what is done, what is in progress and what is blocked.
3. Read the spec for the area you are about to touch (see the map in section 4).
4. Check `docs/decisions/` for any ADR (Architecture Decision Record) that covers the area. ADRs are binding.
5. Check `docs/OPEN-QUESTIONS.md`. If your task depends on an open question, stop and ask the human. Do not guess an answer to a product, pricing, legal or safety question.
6. State in one or two sentences what you are going to do and which milestone task it belongs to. Then start.

If `docs/PROGRESS.md` does not name a current task, pick the first unchecked task in the current milestone of `docs/04-build-plan.md`. Never start work from a later phase while an earlier phase has unchecked exit criteria.

## 2. Session end protocol (do this every time)

1. Run the full verification command (`pnpm verify`, defined in Phase 0). Everything must pass. If it cannot pass, do not commit broken code to `main`; leave the work on a branch and record why in `PROGRESS.md`.
2. Update `docs/PROGRESS.md`: tick finished tasks, add a dated entry to the session log (what changed, what is next, anything surprising).
3. If you made an architectural choice, write an ADR (section 7).
4. If you discovered a question only a human can answer, add it to `docs/OPEN-QUESTIONS.md`.
5. Commit with a clear message (section 9).

## 3. What we are building (one paragraph)

Men sign up, complete an assessment, and get a personalised coaching path made of video, audio and written lessons, challenges and habits. They can chat with **Coach Mia AI** (trained on Mia's own content), upload screenshots of chats and dating profiles for feedback, book 1:1 and group sessions with Mia and guest coaches, join a moderated community, earn streaks and badges, and attend exclusive events and retreats. Revenue comes from subscriptions (bought in the app or on the website), one-off purchases, AI credit top-ups, coaching sessions, events and retreats. Full detail: `docs/00-product-brief.md`.

## 4. Document map

Read in this order the first time. After that, read what your task needs.

| File | What it is | Binding? |
|---|---|---|
| `docs/README.md` | Index and precedence rules | Yes |
| `docs/00-product-brief.md` | What the product does, feature catalogue with IDs (`F-xxx`) | Yes (scope) |
| `docs/01-architecture.md` | System design, stack, repo layout, module rules | Yes |
| `docs/02-engineering-standards.md` | How code is written, tested, reviewed, shipped | Yes |
| `docs/03-data-model.md` | Database conventions and core tables | Yes |
| `docs/04-build-plan.md` | Phases, milestones, tasks, exit criteria | Yes (order) |
| `docs/05-launch-readiness.md` | Release gates and launch checklist | Yes |
| `docs/06-rebuild-traps.md` | The mistakes that force rewrites, and the guardrails | Yes |
| `docs/specs/modules.md` | Every backend module: owns, publishes, consumes | Yes |
| `docs/specs/identity-and-roles.md` | Accounts, roles, permissions | Yes |
| `docs/specs/billing-and-entitlements.md` | Payments, entitlements, credits, payouts | Yes |
| `docs/specs/ai-coach.md` | Coach Mia AI design, safety, cost control | Yes |
| `docs/decisions/` | ADRs: every significant decision and why | Yes |
| `docs/PROGRESS.md` | Live status. Updated every session | Living |
| `docs/OPEN-QUESTIONS.md` | Decisions waiting on a human | Living |
| `docs/GLOSSARY.md` | Exact meaning of every domain word | Yes |

**Precedence when documents disagree:** accepted ADR (newest first) > spec in `docs/specs/` > `01-architecture.md` > `02-engineering-standards.md` > `04-build-plan.md` > anything else. If you find a conflict, do not silently pick one. Fix the lower document in the same change, or raise it in `OPEN-QUESTIONS.md` if the right answer is unclear.

## 5. The non-negotiables

These are the rules that protect the app from a rebuild. Breaking any of them is a defect, even if the code works.

**Architecture**
1. All clients (mobile and web) talk only to our API. No client reads or writes the database directly. Clients may use the auth SDK for sign-in and may upload files to a signed URL the API issued. Nothing else.
2. The API is a modular monolith. A module never imports another module's internals or queries another module's tables. Cross-module calls go through the other module's public interface (`index.ts`) or through domain events. Lint enforces this.
3. Every API endpoint is defined first as a contract in `packages/contracts`. Implementation follows the contract, never the other way round.
4. API changes are backwards compatible. Old app versions stay in users' pockets for months. Additive changes only; anything breaking needs a new endpoint version and an ADR. CI runs a breaking-change check on the OpenAPI output.
5. The app never asks "how did this user pay?" It asks "does this user have entitlement X?" through the billing module.
6. AI provider calls happen only inside the `ai` module, on the server. Never from a client. Never from another module directly.
7. Third-party services sit behind an adapter interface in `apps/api/src/adapters/`. Business code depends on the interface, not on the vendor SDK.

**Data**
8. Money is stored as integer minor units (pence, cents) plus an ISO currency code. Never floats.
9. Timestamps are `timestamptz` in UTC. Users and coaches each store an IANA time zone. Convert at the edges.
10. IDs are UUIDv7, generated by the API.
11. Database changes happen only through migration files in git. Never edit a migration that has been merged to `main`. Never change the production schema by hand.
12. Destructive schema changes use expand and contract (add new, migrate, switch reads, remove old in a later release). Never drop or rename a column in the same release that stops using it.
13. Credits and payments are append-only ledgers. You never update a balance column; you insert a ledger row.

**Safety and security**
14. No secrets in code, logs, commits, screenshots or test fixtures. Configuration comes from environment variables validated at startup.
15. Every endpoint checks authentication and permission in the API. Hiding a button is not security.
16. Sensitive user uploads (chat and profile screenshots) are private, encrypted at rest, accessed only through short-lived signed URLs, and deleted on the schedule in `docs/specs/ai-coach.md`.
17. Never log message contents, screenshot contents, journal entries or AI conversations at info level or above. Log IDs, not content.
18. Webhook handlers verify signatures and are idempotent.

**Quality**
19. No feature is done without tests at the level `02-engineering-standards.md` requires. Never delete, skip or weaken a test to make CI pass. Fix the code or, if the test is wrong, fix the test and explain why in the commit.
20. Every new feature ships behind a feature flag until its milestone exit criteria are met.
21. Business logic never lives in UI components. UI calls hooks; hooks call the API client; rules live in the API (and shared validation lives in `packages/shared`).

## 6. Stop and ask a human when

- The task needs a product, pricing, legal, medical, safety or brand decision.
- You want to add a new third-party vendor or a new paid service.
- You want to add a production dependency that is not already approved in `01-architecture.md` section 4.
- A change would break an existing API contract, drop data, or need a destructive migration.
- A spec is ambiguous or two documents conflict and the right answer is not obvious.
- You are about to touch payments, payouts, credits, auth or data deletion logic in a way the spec does not describe exactly.
- Tests that used to pass now fail for reasons you do not understand.
- You have tried the same fix twice and it has not worked.

When you ask, say what you found, the options, and your recommendation.

## 7. Architecture Decision Records

Any choice that is expensive to reverse gets an ADR in `docs/decisions/NNNN-short-title.md` using `docs/decisions/0000-template.md`. Status is `Proposed`, `Accepted`, `Superseded by NNNN` or `Rejected`. An AI may write a `Proposed` ADR. Only a human moves it to `Accepted`. Never edit the body of an accepted ADR; supersede it with a new one.

## 8. Repo layout (target, created in Phase 0)

```
coach-mia/
  apps/
    mobile/        Expo (React Native) app for iOS and Android
    web/           Next.js: marketing site, web checkout, member web app, coach portal, admin console
    api/           Node API (NestJS), modular monolith, plus worker entry point
  packages/
    contracts/     API contracts (ts-rest + Zod). Single source of truth for every endpoint
    shared/        Pure TypeScript: validation, enums, permission names, pricing rules, date utils
    ui-tokens/     Design tokens (colour, type, spacing) shared by mobile and web
    i18n/          Translation catalogues
    config/        Shared ESLint, TypeScript, Prettier, Vitest config
  docs/            Everything in section 4
  infra/           Docker, deployment blueprints, scripts
```

Inside `apps/api/src/`:

```
modules/<module>/        one folder per module (list in docs/specs/modules.md)
  index.ts               the ONLY file other modules may import
  <module>.controller.ts implements contracts from packages/contracts
  <module>.service.ts    business logic
  <module>.repository.ts database access for this module's tables only
  <module>.events.ts     events this module publishes
  <module>.schema.ts     Drizzle table definitions owned by this module
  __tests__/
adapters/                one folder per third-party service, each behind an interface
platform/                cross-cutting: db, auth guard, permissions, events/outbox, jobs, logging, flags, config
```

## 9. Git and commits

- `main` is always releasable. Work happens on short-lived branches named `<type>/<milestone-id>-<short-desc>`, for example `feat/P1-M4-ai-chat-streaming`.
- Commit messages: Conventional Commits (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`), with the milestone task ID in the body.
- One logical change per commit. Do not mix refactors with features.
- Pull requests must pass every CI gate and include: what changed, why, how it was tested, screenshots for UI changes, and any migration notes.

## 10. Commands (available once Phase 0 milestone M1 is done)

| Command | What it does |
|---|---|
| `pnpm install` | Install everything |
| `pnpm dev` | Run API, worker, web and local services |
| `pnpm dev:mobile` | Run the Expo app |
| `pnpm db:up` | Start local Postgres and Redis in Docker |
| `pnpm db:migrate` | Apply migrations locally |
| `pnpm db:generate` | Generate a new migration from schema changes |
| `pnpm db:seed` | Load realistic seed data |
| `pnpm test` | Unit tests |
| `pnpm test:integration` | Integration tests against a real Postgres |
| `pnpm test:e2e` | End-to-end tests (web: Playwright, mobile: Maestro) |
| `pnpm test:ai-evals` | Coach Mia AI evaluation suite (costs money, run on AI changes) |
| `pnpm lint` | ESLint including module boundary rules |
| `pnpm typecheck` | TypeScript across the monorepo |
| `pnpm contracts:check` | OpenAPI breaking-change check against `main` |
| `pnpm verify` | Everything CI runs, except e2e and AI evals. Must pass before every commit |

Until Phase 0 creates them, these commands do not exist. Do not pretend they ran.

## 11. Definition of done (for any task)

A task is done only when all of these are true:

- [ ] Behaviour matches the spec and the feature catalogue entry.
- [ ] Contract defined in `packages/contracts` and implemented.
- [ ] Permission checks in place and tested (allowed and denied cases).
- [ ] Unit tests for business rules, integration tests for database and API behaviour.
- [ ] Loading, empty, error and offline states handled in the UI.
- [ ] Accessible (labels, Dynamic Type or font scaling, contrast, touch targets).
- [ ] All user-facing text in the i18n catalogue, none hard-coded.
- [ ] Analytics events added per the tracking plan.
- [ ] Behind a feature flag if the milestone is not finished.
- [ ] `pnpm verify` passes.
- [ ] `docs/PROGRESS.md` updated.

## 12. When you are lost

Go back to `docs/PROGRESS.md`. Find the current milestone. Find the next unchecked task. Read its spec. If you still cannot tell what to do, write down what you know and ask. Guessing on this project is more expensive than asking.
