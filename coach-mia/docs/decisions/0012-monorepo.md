# 0012. pnpm and Turborepo monorepo

- **Status:** Proposed
- **Date:** 2026-10-10

## Context
Mobile, web and API share contracts, validation, permissions, tokens and translations.

## Options considered
1. Separate repositories: clear separation, constant version drift between shared packages.
2. Nx monorepo: powerful, more configuration.
3. pnpm workspaces with Turborepo: simple, fast caching, widely understood.

## Decision
pnpm workspaces with Turborepo.

## Consequences
One pull request can change a contract and every client together. CI must use Turborepo caching to stay fast.
