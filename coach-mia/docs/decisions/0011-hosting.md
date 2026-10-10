# 0011. Hosting on Render, Vercel and Supabase with portable containers

- **Status:** Proposed
- **Date:** 2026-10-10

## Context
A small team needs low operational overhead now and a path to larger infrastructure later.

## Options considered
1. AWS from day one (ECS, RDS, S3): most control, high setup and ops cost.
2. Managed platforms: Render for API and worker containers, Vercel for Next.js, Supabase for Postgres, Auth and Storage.

## Decision
Option 2. The API and worker ship as Docker images so they can move to AWS ECS or Fly.io without code changes. Postgres is standard and can move via logical replication.

## Consequences
Fast setup and low ops. Platform limits may be reached at scale; the migration path is documented in `01-architecture.md` section 15.
