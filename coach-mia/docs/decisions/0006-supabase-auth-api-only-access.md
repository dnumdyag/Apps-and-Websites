# 0006. Supabase for auth and storage, all data access through our API

- **Status:** Proposed
- **Date:** 2026-10-10

## Context
We need reliable sign-in (Apple, Google, email), file storage and hosted Postgres, without coupling app logic to a backend-as-a-service.

## Options considered
1. Supabase used directly from clients with Row Level Security: fastest start, but business rules spread into database policies and clients, and old app versions break when tables change.
2. Supabase as infrastructure (Postgres, Auth, Storage) with all data access through our API.
3. Separate providers (Clerk or Auth0 for auth, AWS for database and storage): more vendors, more cost.

## Decision
Option 2. Clients use the Supabase Auth SDK only to sign in, and upload files only to signed URLs our API issues. RLS is enabled with no client policies as defence in depth. Auth and storage sit behind `AuthAdapter` and `StorageAdapter`.

## Consequences
We write our own endpoints for everything (more code, full control). Moving off Supabase later means migrating auth users and repointing adapters, not rewriting features.
