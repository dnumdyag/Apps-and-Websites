# 0009. RevenueCat and Stripe behind an entitlements model

- **Status:** Proposed
- **Date:** 2026-10-10

## Context
Members can pay in the App Store, Google Play or on the web (often cheaper). Access can also come from trials, referrals, promos and admin grants. Store rules on external purchase links vary by country and change over time.

## Options considered
1. Direct StoreKit and Play Billing integration: maximum control, a lot of edge-case code.
2. RevenueCat for store purchases plus Stripe for web, both feeding our own entitlements table.

## Decision
Option 2. Our `billing` module is the source of truth for access, exposed only through `hasEntitlement`. Purchase routes shown in the app are server configuration per country.

## Consequences
RevenueCat fee on store revenue above its free tier. All access logic is one function, so new payment routes do not touch features.
