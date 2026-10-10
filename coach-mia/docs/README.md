# Coach Mia Build Docs

These documents are the single source of truth for how Coach Mia is designed and built. They are written so that a human developer, an agency or an AI agent can pick up the work at any point without losing the thread.

## Reading order

1. [00-product-brief.md](00-product-brief.md): what we are building and why. Feature catalogue with IDs.
2. [01-architecture.md](01-architecture.md): how the system fits together, the stack, the repo layout.
3. [02-engineering-standards.md](02-engineering-standards.md): how code is written, tested and shipped.
4. [03-data-model.md](03-data-model.md): database conventions and the core tables.
5. [04-build-plan.md](04-build-plan.md): the phased plan, milestones, tasks and exit criteria.
6. [05-launch-readiness.md](05-launch-readiness.md): the gates every release must pass.
7. [06-rebuild-traps.md](06-rebuild-traps.md): what causes rewrites, and how we prevent each one.
8. [specs/](specs/): detailed specs for the systems that are hardest to change later.
9. [decisions/](decisions/): Architecture Decision Records.
10. [GLOSSARY.md](GLOSSARY.md): exact meaning of domain words.

Living documents, updated as work happens:

- [PROGRESS.md](PROGRESS.md): current phase, milestone, task status and session log.
- [OPEN-QUESTIONS.md](OPEN-QUESTIONS.md): decisions waiting on a human.

## Precedence

When two documents disagree, the higher one wins:

1. Accepted ADRs in `decisions/` (newest first)
2. Specs in `specs/`
3. `01-architecture.md`
4. `02-engineering-standards.md`, `03-data-model.md`
5. `04-build-plan.md`, `05-launch-readiness.md`
6. Everything else

A conflict is a bug in the docs. Fix the lower document in the same change, or log it in `OPEN-QUESTIONS.md`.

## How these docs change

- Docs change in the same pull request as the code that makes them true. A PR that changes behaviour without updating the relevant doc is incomplete.
- Significant or hard-to-reverse decisions get an ADR. ADRs are never edited after acceptance; they are superseded.
- The original stakeholder brief ("Coach Mia sum up") is treated as a direction, not a specification. Where this documentation interprets or narrows it, the interpretation is recorded in `00-product-brief.md` or an ADR.
