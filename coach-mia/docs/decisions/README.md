# Architecture Decision Records

An ADR records a decision that is expensive to reverse, the context, the options considered and the consequences. Use `0000-template.md`.

Rules:
- Number sequentially. Never reuse a number.
- Status: `Proposed` → `Accepted` (by a human) → optionally `Superseded by NNNN`. Or `Rejected`.
- An AI may write `Proposed` ADRs. Only a human sets `Accepted`.
- Never edit the decision in an accepted ADR. Write a new ADR that supersedes it.

| ADR | Title | Status |
|---|---|---|
| [0001](0001-custom-build-and-adrs.md) | Custom build, decisions recorded as ADRs | Proposed |
| [0002](0002-expo-react-native.md) | Expo (React Native) for iOS and Android | Proposed |
| [0003](0003-nestjs-modular-monolith.md) | NestJS modular monolith for the API | Proposed |
| [0004](0004-contract-first-ts-rest.md) | Contract-first API with ts-rest and Zod | Proposed |
| [0005](0005-postgres-pgvector-drizzle.md) | PostgreSQL with pgvector, Drizzle ORM | Proposed |
| [0006](0006-supabase-auth-api-only-access.md) | Supabase for auth and storage, all data access through our API | Proposed |
| [0007](0007-outbox-and-pg-boss.md) | Domain events via transactional outbox, jobs via pg-boss | Proposed |
| [0008](0008-claude-gateway-and-rag.md) | Claude via an LLM gateway, retrieval instead of fine-tuning | Proposed |
| [0009](0009-revenuecat-stripe-entitlements.md) | RevenueCat and Stripe behind an entitlements model | Proposed |
| [0010](0010-ai-credits-ledger.md) | AI usage paid with credits from an append-only ledger | Proposed |
| [0011](0011-hosting.md) | Hosting on Render, Vercel and Supabase with portable containers | Proposed |
| [0012](0012-monorepo.md) | pnpm and Turborepo monorepo | Proposed |
