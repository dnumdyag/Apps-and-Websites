# 0008. Claude via an LLM gateway, retrieval instead of fine-tuning

- **Status:** Proposed
- **Date:** 2026-10-10

## Context
Coach Mia AI must answer in Mia's voice from Mia's content, analyse screenshots, stay safe and ethical, and keep costs predictable. Models improve and change often.

## Options considered
1. Fine-tune a model on Mia's content: expensive, slow to update, hard to keep current.
2. Retrieval over Mia's content plus a carefully written system prompt, through a provider gateway.

## Decision
Option 2 using Anthropic's Claude API as the provider. All calls go through `adapters/llm`. Features request a tier; config maps tiers to model IDs. Prompts are versioned and gated by an evaluation suite.

## Consequences
New content improves the AI as soon as it is published. Model upgrades are configuration changes gated by evals. Another provider could be added behind the same gateway if needed.
