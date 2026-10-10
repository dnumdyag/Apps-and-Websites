# 0001. Custom build, decisions recorded as ADRs

- **Status:** Proposed
- **Date:** 2026-10-10

## Context
Coach Mia needs AI usage metering, a web and in-app payment split, coach payouts, a member-to-coach pathway, screenshot analysis and moderated community. The stakeholder wants to avoid rebuilding after the MVP.

## Options considered
1. No-code or low-code builder (FlutterFlow, Bubble, Adalo): fast prototypes, but cannot handle secure AI metering, payment split or payouts well. Migration later is a rebuild.
2. White-label coaching platform (Kajabi, Mighty Networks, Circle): courses and community out of the box, but no control over AI, credits, gamification or the coach pathway; users and data are hard to move later.
3. Custom build on mainstream open tools: more upfront work, full control, no forced rebuild.

## Decision
Custom build (option 3), following the architecture in `01-architecture.md`. Significant decisions are recorded as ADRs in this folder.

## Consequences
Higher initial cost than options 1 and 2. Every foundation is designed once for the full app. A white-label tool may still be used briefly to validate demand before launch, but nothing built on it is carried into this codebase.
