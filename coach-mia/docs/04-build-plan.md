# 04. Build Plan

The plan is split into phases. Each phase is split into milestones. Each milestone has tasks and **exit criteria**. A milestone is not finished until every exit criterion is true. A phase cannot start until the previous phase's exit criteria are met (work can be prepared on branches, but not merged behind an unfinished foundation).

Task IDs: `P<phase>-M<milestone>-T<task>`, for example `P1-M4-T3`. Use them in branch names, commits and `PROGRESS.md`.

Rule of thumb: **build thin vertical slices.** Each milestone delivers something that works end to end (database to screen) and is tested, rather than building all back end first and all front end later.

---

## Phase 0: Foundations

Goal: a production-grade skeleton. No product features yet, but every hard foundation in place, deployed and tested. This is the phase that prevents rebuilds. Do not rush it.

### P0-M1: Repository and tooling
- T1: Create monorepo (pnpm workspaces, Turborepo) with the layout in `CLAUDE.md` section 8.
- T2: Shared TypeScript, ESLint (including boundary rules), Prettier and Vitest config in `packages/config`.
- T3: `docker-compose` for local Postgres (with pgvector) and Redis. `pnpm db:up`.
- T4: All `pnpm` commands from `CLAUDE.md` section 10 wired up (some will be no-ops until later milestones; they must still run and pass).
- T5: `.env.example` for every app; Zod-validated config loader in each app that fails fast on missing variables.
- T6: Pre-commit hooks: lint-staged, gitleaks.
- T7: GitHub Actions CI with every gate from standards section 11.2 that can run at this stage.
- T8: Renovate config, CodeQL, branch protection on `main`.

**Exit criteria:** a fresh clone runs `pnpm install && pnpm db:up && pnpm verify` green. CI green on a sample PR. Boundary lint rule proven by a deliberately failing test case.

### P0-M2: API skeleton and platform layer
- T1: NestJS app with Fastify adapter, `main.ts` and `worker.ts` entry points.
- T2: `platform/db`: Drizzle setup, connection pool, transaction helper, migration runner.
- T3: `platform/config`, `platform/logging` (pino, request IDs, redaction rules), `platform/errors` (standard error shape, global filter).
- T4: `platform/events`: outbox table, event bus, dispatcher, `processed_events` idempotency.
- T5: `platform/jobs`: pg-boss setup, retry and dead-letter policy, scheduled jobs support.
- T6: `platform/idempotency`: Idempotency-Key middleware.
- T7: `platform/rate-limit` (Redis).
- T8: `platform/clock` and `platform/crypto` (envelope encryption helpers).
- T9: `packages/contracts` with ts-rest, a `health` contract and `GET /v1/app-config`; OpenAPI generation and `pnpm contracts:check`.
- T10: Testcontainers integration test harness and factories.

**Exit criteria:** health and app-config endpoints served from contracts; an event written in a transaction is dispatched exactly once to a test subscriber even if the subscriber runs twice; a job retries then dead-letters; all covered by tests.

### P0-M3: Identity, roles and permissions
- T1: Supabase Auth projects for local, staging, production. Apple, Google, email providers configured.
- T2: `AuthAdapter` interface and Supabase implementation; JWT verification via JWKS.
- T3: `identity` module: `users`, `role_assignments`, `profiles`, `devices`, `consents`; user record created on first authenticated call.
- T4: Permission constants and role map in `packages/shared/permissions.ts`; permission guard; ownership helper.
- T5: Endpoints: `GET /v1/me`, `PATCH /v1/me`, `POST /v1/me/devices`, `POST /v1/me/consents`.
- T6: Account deletion request flow (F-106) skeleton: request, grace period job, deletion orchestrator that calls each module's `eraseUser(userId)` (empty implementations allowed now, but every module must implement it when it adds personal data).
- T7: Admin bootstrap script to grant the first admin role.

**Exit criteria:** integration tests prove allowed and forbidden access for every role on a sample protected endpoint; deletion orchestrator test passes; spec `specs/identity-and-roles.md` matches the code.

### P0-M4: Billing foundations (no real products yet)
- T1: `billing` module tables: products, prices, entitlement definitions, product entitlements, entitlement grants, purchases, subscriptions, credit ledger, credit wallets, webhook events.
- T2: `hasEntitlement`, `listEntitlements`, `grantEntitlement`, `revokeEntitlement` with tests.
- T3: Credits: `getBalance`, `reserve`, `settle`, `release`, `grant`, monthly allowance job. Concurrency test: 50 parallel reservations never overspend.
- T4: RevenueCat project (sandbox) and webhook endpoint with signature verification and idempotency; maps events to grants.
- T5: Stripe account (test mode) and webhook endpoint with signature verification and idempotency.
- T6: `GET /v1/me/entitlements` and `GET /v1/me/credits`.

**Exit criteria:** a sandbox purchase in RevenueCat and a test-mode Stripe purchase both produce the same entitlement grant; replaying any webhook twice changes nothing; out-of-order webhooks resolve correctly; ledger tests at 90%+ coverage.

### P0-M5: Mobile and web shells
- T1: Expo app with Expo Router, NativeWind, tokens, i18n, TanStack Query, ts-rest client, secure token storage, Sentry, PostHog, app-config check with force-update screen.
- T2: Sign in with Apple, Google, email on mobile, round trip to `GET /v1/me`.
- T3: Next.js app with route groups `(marketing)`, `(checkout)`, `(member)`, `(coach)`, `(admin)`, each with its access guard; sign-in; Sentry; PostHog.
- T4: Core UI kit on both platforms: buttons, inputs, cards, list rows, sheets, toasts, empty, error and loading states. Dark mode.
- T5: Feature flag wrapper on both clients and the API.
- T6: Maestro and Playwright smoke tests for sign-in.

**Exit criteria:** a tester can install a TestFlight and Play internal build, sign in with Apple or Google, and see their name from the API in staging. Web sign-in works in staging. Smoke tests green in CI.

### P0-M6: Environments, deployment and operations
- T1: Staging and production on Render (API and worker containers), Vercel (web), Supabase (database, auth, storage), with separate vendor sandboxes and keys.
- T2: Deploy pipeline: merge to `main` → staging; manual promotion to production; migrations as a separate step.
- T3: EAS Build profiles (development, preview, production) and EAS Update channels.
- T4: Point-in-time recovery on; a documented and **tested** restore into a scratch database.
- T5: Uptime checks, alerting (queue depth, dead letters, error rate, latency) to a shared channel.
- T6: `infra/RUNBOOK.md` with every runbook listed in standards section 12, at least in outline.

**Exit criteria:** a deliberate bad deploy is rolled back in under 10 minutes following the runbook; a database restore drill succeeds; alerts fire on a simulated failure.

### Phase 0 exit criteria
- All milestones complete.
- `PROGRESS.md` and every spec accurate.
- A human has reviewed and accepted ADRs 0001 to 0012.

---

## Phase 1: MVP (launchable product)

Goal: the smallest product that delivers the core promise and can make money. Features: F-001 to F-016 (basic), F-020, F-021, F-030, F-033, F-035, F-036, F-040, F-045, F-046, F-060 (daily tip), F-061, F-062 (core set), F-064, F-080, F-081, F-082, F-086, F-090 (Mia only), F-100, F-101, F-102 (core), F-103, F-106.

### P1-M1: Content system and admin content tools
- Content tables, Mux adapter and webhooks, upload flow from admin, publish workflow (draft, published, archived), collections.
- Admin console: create and edit lessons (Markdown editor with preview), upload media, manage collections, preview as a member.
- Member endpoints: browse collections, lesson detail, progress update, continue watching.
- Access checks by `access_level` through `billing.hasEntitlement`.
- Exit: Mia's team can publish a video, audio and guide lesson end to end; a free member sees free content and a paywall on premium; progress resumes across devices.

### P1-M2: Onboarding, assessment and roadmap
- Welcome flow with Mia video, goals, assessment (data-driven questions), onboarding progress bar, guided tour, first action step, contextual notification prompt, guest mode with migration on sign-up.
- Roadmap generator (rules first: goals plus assessment result map to ordered steps; AI ranking can come later).
- Exit: a new user completes onboarding in under 3 minutes on a mid-range phone and lands on a personalised dashboard; guest progress survives sign-up; funnel analytics events present for every step.

### P1-M3: Home dashboard, progress and core gamification
- Dashboard: daily tip or challenge, suggested next steps from roadmap, continue watching, upcoming session, streak.
- Gamification module: points ledger, streaks (computed in the user's time zone), core badges, levels, subscriptions to content and onboarding events.
- Exit: completing a lesson updates progress, points, streak and badges through events only (no direct calls from content to gamification); streak tests cover time zone changes and daylight saving.

### P1-M4: Coach Mia AI chat (F-030, F-033, F-035, F-036)
- Knowledge ingestion pipeline: published content → chunks → embeddings → `knowledge_chunks`; re-ingest on publish and edit.
- Provider gateway (`adapters/llm`), prompt registry with versions, model tier config.
- Chat endpoint with streaming responses, retrieval, user memory summary, credit reservation and settlement.
- Pasted text message breakdown.
- Safety layer: input and output checks, crisis detection and routing to support resources, refusal handling, ethics rules, disclaimers.
- Evaluation suite v1: at least 150 cases across voice, accuracy, ethics, safety and crisis. Must pass thresholds in `specs/ai-coach.md`.
- AI consent screen before first use.
- Exit: eval thresholds met; credit balance never goes negative under concurrency tests; AI spend per user visible in admin; crisis test cases route correctly 100% of the time.

### P1-M5: Subscriptions and paywalls (F-080, F-081, F-082, F-086)
- Products and prices configured for app stores (via RevenueCat offerings) and web (Stripe).
- Paywall screens with plans, trial, restore purchases, manage subscription.
- Web checkout pages, customer portal, account linking (web purchase grants access in the app on the same account).
- Purchase route config per country served by `/v1/app-config`.
- Monthly AI credit allowance per tier; credit top-up packs.
- Exit: in sandbox, buy on iOS, Android and web, and in every case entitlements appear on all three within 10 seconds; cancellation, expiry, refund, billing retry and grace period all handled and tested; restore purchases works on a fresh install.

### P1-M6: 1:1 booking with Mia and calls (F-040, F-045, F-046, F-090)
- Coach profile for Mia, availability rules and exceptions, slot generation in both time zones, hold-then-confirm flow with payment or entitlement, cancellation and reschedule policy, reminders, calendar invites (ICS), Daily.co rooms with tokens, post-session notes, review.
- Coach portal (web): availability, upcoming sessions, notes.
- Payment links for sessions created from admin.
- Exit: double booking impossible (database constraint tested under concurrency); daylight-saving boundary tests pass; a full booking → call → notes → review loop works in staging on real devices.

### P1-M6b: Notifications and email (F-100, F-101)
- Notifications module, preferences, quiet hours, templates, inbox, push via Expo, email via Resend.
- Lifecycle messages: welcome, streak at risk, session reminders, trial ending, payment failed.
- Exit: every notification respects preferences and quiet hours in tests; unsubscribe links work; no duplicate sends when jobs retry.

### P1-M7: Admin console core (F-102) and analytics (F-103)
- User lookup, roles, entitlements view, credit adjustments (audited), refunds (via Stripe or store guidance), content tools from M1, AI usage dashboard, audit log viewer.
- Tracking plan implemented across all Phase 1 features; dashboards for the success metrics in the product brief.
- Exit: every admin write action appears in the audit log; analytics dashboards show real staging data.

### P1-M8: Hardening and launch
- Everything in `05-launch-readiness.md` for a Phase 1 launch.
- Beta programme (TestFlight and Play closed testing) with real users for at least 3 weeks.
- Exit: all launch gates green; store approval obtained; staged rollout plan agreed.

### Phase 1 exit criteria
- App live in both stores and on the web.
- Crash-free sessions 99.5%+ over the beta's final week.
- No open P0 or P1 bugs.
- All Phase 1 features behind flags at 100% or deliberately held back by a human decision.

---

## Phase 2: Growth

Features: F-013 (attachment test), F-017, F-018, F-019, F-022, F-023, F-024, F-025, F-031, F-032, F-041, F-042, F-050, F-051, F-052, F-054, F-055, F-060 (full), F-062 (full), F-083, F-084, F-085, F-090 (guests), F-091.

Milestones (each with tasks and exit criteria written into this file before work starts):
- **P2-M1: Moderation system first** (F-055): reporting, AI pre-screen, moderator queue, sanctions, audit. Must be live before any community feature.
- **P2-M2: Community** (F-050, F-051, F-052, F-054).
- **P2-M3: Screenshot analysis** (F-031, F-032): private upload pipeline, image re-encoding and metadata stripping, vision analysis, auto-deletion, consent.
- **P2-M4: Self-work tools** (F-022, F-023, F-024, F-025, F-019).
- **P2-M5: Guest coaches and payouts** (F-041, F-042, F-090, F-091): coach onboarding, Stripe Connect, commission rules, payout runs, group sessions.
- **P2-M6: Growth mechanics** (F-083, F-084, F-085, F-017, F-018, full challenges and badges, F-013 attachment test).
- **P2-M7: Hardening and release.**

## Phase 3: Full platform

Features: F-034, F-043, F-044, F-053, F-063, F-070, F-071, F-072, F-092, F-104, F-105.

Milestones (detailed before work starts):
- **P3-M1: Events and retreats** (F-070, F-071).
- **P3-M2: Partner venues** (F-072).
- **P3-M3: Webinars and coach messaging** (F-043, F-044).
- **P3-M4: Accountability groups and leaderboards** (F-053, F-063).
- **P3-M5: Member-to-coach pathway** (F-092).
- **P3-M6: Date planner and review** (F-034).
- **P3-M7: Localisation** (F-104) and **relationship track** (F-105).
- **P3-M8: Hardening and release.**

## How to add detail to a later phase

Before a phase starts, a human and the AI write its milestones out at the same level of detail as Phase 1 (tasks plus exit criteria), confirm open questions are answered, and record any new decisions as ADRs. Do not start a milestone whose exit criteria are not written down.
