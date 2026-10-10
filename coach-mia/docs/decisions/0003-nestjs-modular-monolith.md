# 0003. NestJS modular monolith for the API

- **Status:** Proposed
- **Date:** 2026-10-10

## Context
The full app has about a dozen business areas. We need clear boundaries without the cost of microservices.

## Options considered
1. Microservices from day one: independent scaling, heavy operational cost, slow delivery.
2. Unstructured monolith (or serverless functions per endpoint): fast at first, tangles as features grow.
3. Modular monolith on a structured framework: one deployable, enforced internal boundaries, extraction path per module.

## Decision
A modular monolith built with NestJS (Fastify adapter). One Postgres schema per module. Boundaries enforced by lint and dependency-cruiser. A separate worker process from the same codebase.

## Consequences
Simple deployment and debugging. Boundary rules must be enforced in CI or they erode. Modules can be extracted to services later (the `ai` module is the most likely first candidate).
