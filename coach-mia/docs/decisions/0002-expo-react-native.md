# 0002. Expo (React Native) for iOS and Android

- **Status:** Proposed
- **Date:** 2026-10-10

## Context
We need iOS and Android apps from a small team, sharing language and logic with the web and API. The product's value is content, AI, coaching and community rather than device-specific features.

## Options considered
1. Fully native (Swift and Kotlin): best platform fidelity, two codebases, roughly double cost.
2. Flutter: excellent UI, but Dart separates mobile from the TypeScript web and API.
3. Kotlin Multiplatform: shared logic, still two UIs, web not covered.
4. Expo (React Native) with TypeScript: one codebase, shared types and validation with web and API, over-the-air updates, large talent pool.

## Decision
Expo with Expo Router, using dev builds and config plugins so any native module can be added when needed.

## Consequences
Shared TypeScript across the stack. Some native polish (widgets, Live Activities) needs native modules later. Expo SDK upgrades must be scheduled (within 8 weeks of each release).
