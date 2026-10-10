# 0005. PostgreSQL with pgvector, Drizzle ORM

- **Status:** Proposed
- **Date:** 2026-10-10

## Context
Data is highly relational (users, coaches, bookings, purchases, entitlements, payouts, referrals). The AI needs vector search over Mia's content.

## Options considered
1. Document database (Firestore): flexible, but poor fit for relational and financial data.
2. Proprietary reactive database (Convex): great developer experience, higher lock-in.
3. PostgreSQL with pgvector: relational integrity, constraints (for example no double booking), vector search, portable across hosts.

## Decision
PostgreSQL 16+ with pgvector. Drizzle ORM and drizzle-kit migrations.

## Consequences
One database for relational and vector data at launch. Portable to any Postgres host. A dedicated vector store can be added later behind an interface if needed.
