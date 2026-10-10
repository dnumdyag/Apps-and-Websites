# 06. Rebuild Traps

These are the mistakes that typically force a rewrite late in a project like this, why they happen, and the guardrail that stops each one here. If you (human or AI) are about to do something that resembles the "trap" column, stop and re-read the guardrail.

| # | Trap | Why it forces a rebuild | Guardrail in this project |
|---|---|---|---|
| 1 | Clients talk directly to the database or backend-as-a-service tables | Business rules end up scattered in apps; security depends on database policies; changing a table breaks old app versions in users' pockets | All traffic through our API (CLAUDE.md rule 1). RLS on with no client policies |
| 2 | Payment logic tied to one store ("if iOS then...") | Adding web payments, Android, promos, referrals or admin grants means rewriting access checks everywhere | Entitlements abstraction: one `hasEntitlement` check, many grant sources (spec: billing) |
| 3 | Roles modelled as account types (a "coach account" separate from a "member account") | The member-to-coach pathway (F-092) and Mia being coach plus admin become impossible without data migration | One account, many roles (spec: identity) |
| 4 | AI calls scattered through the code, model names hard-coded | Cost control, safety, provider changes and model upgrades each need changes everywhere | One `ai` module, provider gateway, model IDs in config, prompts versioned |
| 5 | AI usage not metered from day one | Discovering at scale that heavy users cost more than they pay; retrofitting limits angers users | Credits ledger and per-call metering in Phase 0 and Phase 1 |
| 6 | Breaking API changes shipped to mobile | Old app versions crash or lose data; forced updates anger users | Contracts, additive-only rule, `oasdiff` in CI, minimum version endpoint |
| 7 | Time stored in local time or without time zones | Bookings across time zones, streaks at midnight and reminders all go wrong; fixing requires data migration | UTC `timestamptz` + IANA time zone per user and coach; shared date helpers; DST tests |
| 8 | Money as floats, or prices hard-coded in the app | Rounding errors in payouts; price changes need app releases | Integer minor units; prices from the catalogue via API |
| 9 | Balance columns updated in place | Lost updates under concurrency, no audit trail, impossible reconciliation | Append-only ledgers with row-locked wallets |
| 10 | Modules reaching into each other's tables | Any change ripples everywhere; nothing can be extracted later | Schema per module, boundary lint, events via outbox |
| 11 | Side effects called directly ("after purchase, call gamification, then email, then analytics") | Partial failures leave inconsistent state; every new feature edits old code | Transactional outbox + idempotent subscribers |
| 12 | Hand-edited production database or edited migrations | Environments drift; deploys fail unpredictably | Migrations only, never edit merged migrations, drift check in CI |
| 13 | Vendor SDKs used throughout the code | Vendor price rises or outages force a rewrite | Adapters with interfaces and fakes |
| 14 | Strings hard-coded in screens | Localisation (F-104) means touching every screen | i18n catalogue from the first screen |
| 15 | Moderation added after community launches | Store rejection (user-generated content rules), reputation damage, rework of post flows | Moderation milestone (P2-M1) must ship before community (P2-M2); posts have a `status` from day one |
| 16 | Privacy and deletion bolted on at the end | Store rejection; legal exposure; personal data spread through tables nobody tracked | `eraseUser` contract per module from P0-M3; data inventory; retention rules |
| 17 | Testing left until the end | Late discovery of design flaws in the hardest code (payments, bookings, AI credits) | Tests in every task's definition of done; coverage floors on critical modules |
| 18 | One giant "launch" release | Too many unknowns at once; launch date slips; bugs found by real users | Feature flags, staged rollouts, beta programme, phase gates |
| 19 | Undocumented decisions | New developers or AI sessions reverse earlier choices without knowing why | ADRs, precedence rules, `PROGRESS.md` session log |
| 20 | AI agent drifting across sessions | Duplicate patterns, half-finished features, inconsistent conventions | Session start and end protocol in CLAUDE.md, single current task, stop-and-ask list |
| 21 | Building on a no-code or white-label tool to "save time" | Hits a wall on AI metering, payments split, payouts; migration later is a rebuild | Decided against (ADR 0001 context) |
| 22 | Premature microservices | Operational overload slows every feature | Modular monolith with an extraction path (architecture section 15) |
| 23 | Ignoring app store rules until submission | Rejection late in the schedule; payment flows redesigned | Store rules reviewed at each phase start; purchase routes configurable per country |
| 24 | Unbounded realtime or polling design for community | Costs and load explode as members grow | Cursor pagination, push for notifications, realtime added behind an adapter only when needed |
| 25 | No restore drill | Discovering backups do not work during an incident | Restore tested in P0-M6 and every 30 days before launches |
