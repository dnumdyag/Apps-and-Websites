# Progress

This file is the live status of the build. Every AI or human session reads it first and updates it last.

## Current position

| Field | Value |
|---|---|
| Phase | 0: Foundations |
| Milestone | P0-M1: Repository and tooling |
| Current task | None started. Next: P0-M1-T1 (create monorepo) |
| Blocked on | Human acceptance of ADRs 0001 to 0012; answers to blocking questions in `OPEN-QUESTIONS.md` marked "Blocks Phase 0" |
| Last updated | 2026-10-10 |

## Phase status

| Phase | Status |
|---|---|
| Planning docs | Done |
| Phase 0: Foundations | Not started |
| Phase 1: MVP | Not started |
| Phase 2: Growth | Not started |
| Phase 3: Full platform | Not started |

## Phase 0 checklist

### P0-M1: Repository and tooling
- [ ] T1 Monorepo created
- [ ] T2 Shared config (TS, ESLint with boundaries, Prettier, Vitest)
- [ ] T3 Local Postgres (pgvector) and Redis via Docker
- [ ] T4 All `pnpm` commands wired
- [ ] T5 `.env.example` and validated config loaders
- [ ] T6 Pre-commit hooks
- [ ] T7 CI pipeline
- [ ] T8 Renovate, CodeQL, branch protection
- [ ] Exit criteria met

### P0-M2: API skeleton and platform layer
- [ ] T1 to T10 (see build plan)
- [ ] Exit criteria met

### P0-M3: Identity, roles and permissions
- [ ] T1 to T7
- [ ] Exit criteria met

### P0-M4: Billing foundations
- [ ] T1 to T6
- [ ] Exit criteria met

### P0-M5: Mobile and web shells
- [ ] T1 to T6
- [ ] Exit criteria met

### P0-M6: Environments, deployment and operations
- [ ] T1 to T6
- [ ] Exit criteria met

Expand each milestone's tasks into individual checkboxes when the milestone starts.

## Known issues and tech debt

| ID | Description | Severity | Logged |
|---|---|---|---|
| (none yet) | | | |

## Session log

Newest first. One entry per working session: date, who (human name or "AI"), what changed, what is next, anything surprising.

### 2026-10-10 (AI)
- Created the planning documentation set: operating manual (`CLAUDE.md`), product brief with feature catalogue, architecture, engineering standards, data model, build plan, launch readiness, rebuild traps, module, identity, billing and AI specs, ADRs 0001 to 0012, glossary, open questions.
- Next: a human reviews and accepts the ADRs and answers the "Blocks Phase 0" questions. Then start P0-M1-T1.
