# Open Questions

Decisions only a human can make. An AI must not guess the answer to any question here. When a question is answered, move it to the "Answered" section with the answer, date and who decided, and update the affected docs in the same change.

Blocking level: **Blocks Phase 0**, **Blocks Phase 1**, **Blocks Phase 2**, **Blocks Phase 3**, or **Non-blocking**.

## Open

| ID | Question | Why it matters | Blocks | Owner |
|---|---|---|---|---|
| Q-001 | Which country or countries launch first? | Store purchase rules, pricing currency, crisis resources, data protection law, language | Phase 0 (auth and legal setup), Phase 1 | Business |
| Q-002 | Which legal entity owns the app and the vendor accounts (Apple, Google, Stripe, Anthropic)? | Store accounts take time to verify; contracts and data processing agreements | Phase 0 | Business |
| Q-003 | Who is the technical owner who accepts ADRs and approves sensitive PRs? | Someone must hold the decision rights in CLAUDE.md | Phase 0 | Business |
| Q-004 | Final tiers (Free, Premium, VIP): exactly what each includes | Paywalls, entitlements, AI allowance | Phase 1 | Business + Mia |
| Q-005 | Prices per tier on app stores and on the web | Catalogue, paywall, web checkout | Phase 1 | Business |
| Q-006 | Monthly AI credit allowance per tier, top-up pack sizes and prices, credit rate | AI cost control and margin | Phase 1 | Business (with cost data from P1-M4 evals) |
| Q-007 | Free trial length and which tier it applies to | Store and Stripe config | Phase 1 | Business |
| Q-008 | 1:1 session lengths, prices, cancellation and reschedule policy | Bookings and billing | Phase 1 | Mia |
| Q-009 | Collect date of birth, or only confirm 18+? | Age gate design and data minimisation | Phase 1 | Business + legal |
| Q-010 | Screenshot retention: confirm 24-hour auto-deletion default | Privacy promise and storage rules | Phase 2 | Business + legal |
| Q-011 | Coach commission rate and payout schedule | Payouts | Phase 2 | Business |
| Q-012 | Referral reward mechanics (free month vs. discount, for store and web subscribers) | Referral implementation | Phase 2 | Business |
| Q-013 | Community moderation staffing and hours; response time targets | Moderation queue design and store compliance | Phase 2 | Business |
| Q-014 | Member-to-coach pathway: exact eligibility, training, and how these coaches are paid | F-092 | Phase 3 | Mia |
| Q-015 | Partner venues: listing only, or paid partnerships with offers and a partner portal? | F-072 scope | Phase 3 | Business |
| Q-016 | Is iPad support required at launch? | Layouts and testing matrix | Phase 1 | Business |
| Q-017 | Brand: name in stores, visual identity, Mia's style guide for the AI voice | Design system tokens and AI prompt | Phase 1 | Mia |
| Q-018 | Purchased credits expiry (proposed 12 months) | Ledger rules and consumer law | Phase 1 | Business + legal |
| Q-019 | Is "matchmaking" (mentioned once in the brief) ever in scope? Currently out of scope | Avoids accidental scope creep | Non-blocking | Business |

## Answered

| ID | Question | Answer | Date | Decided by |
|---|---|---|---|---|
| (none yet) | | | | |
