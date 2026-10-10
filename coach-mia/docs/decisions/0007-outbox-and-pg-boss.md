# 0007. Domain events via transactional outbox, jobs via pg-boss

- **Status:** Proposed
- **Date:** 2026-10-10

## Context
Many features react to the same actions (a lesson completion updates progress, points, streaks, roadmap and notifications). Direct calls between modules create tangles and partial failures.

## Options considered
1. Direct calls: simple, tightly coupled, inconsistent on failure.
2. Redis-based queue (BullMQ) plus events: robust, but enqueueing is not in the same transaction as the database write.
3. Transactional outbox in Postgres plus pg-boss: events written atomically with state changes, no extra infrastructure.
4. Managed workflow service (Inngest, Trigger.dev): good tooling, another vendor in the critical path.

## Decision
Option 3. Events are written to `platform.outbox` in the same transaction; a dispatcher enqueues pg-boss jobs per subscriber; subscribers are idempotent.

## Consequences
At-least-once delivery, so every subscriber must be idempotent. Queue throughput is bounded by Postgres; revisit if job volume grows very large.
