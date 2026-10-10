# 0004. Contract-first API with ts-rest and Zod

- **Status:** Proposed
- **Date:** 2026-10-10

## Context
Mobile apps stay installed for months, so the API must not break old versions. Server and clients must agree on shapes at compile time.

## Options considered
1. tRPC: excellent type safety, but no stable REST surface or OpenAPI for versioning checks and third parties.
2. Hand-written OpenAPI with generated clients: language neutral, more ceremony, drift risk.
3. ts-rest contracts with Zod: REST endpoints, shared types, runtime validation, OpenAPI generated for breaking-change checks.

## Decision
ts-rest contracts with Zod schemas in `packages/contracts`. OpenAPI generated in CI and compared with `oasdiff` against `main` to block breaking changes.

## Consequences
Every endpoint starts as a contract. Breaking changes require `/v2` endpoints and a new ADR.
