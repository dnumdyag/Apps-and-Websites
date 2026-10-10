# 0010. AI usage paid with credits from an append-only ledger

- **Status:** Proposed
- **Date:** 2026-10-10

## Context
AI cost grows with usage and depth of questions. The stakeholder suggested a minutes-based allowance (60 to 90 minutes a month).

## Options considered
1. Minutes of usage: easy to explain, poorly related to actual cost, hard to measure for text chat.
2. Unlimited: simple, but heavy users can cost more than they pay.
3. Credits based on actual cost: fair, predictable, supports top-ups and tiered allowances.

## Decision
Credits (option 3), recorded in an append-only ledger with reservation and settlement around each AI call. Users see friendly estimates ("about 40 more chats"), not raw credits or tokens.

## Consequences
Requires careful concurrency handling and good UX for running low. Allowance sizes and prices are business configuration, not code.
