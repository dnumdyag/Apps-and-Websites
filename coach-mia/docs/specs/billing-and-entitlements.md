# Spec: Billing, Entitlements and Credits

This is the most expensive area to get wrong. Read it fully before changing anything in `modules/billing`.

## 1. Core idea

The rest of the app never knows how someone paid. It asks one question:

```ts
billing.hasEntitlement(userId, "premium")   // true or false
```

Everything that grants access writes a row into `billing.entitlement_grants`. Everything that checks access reads through `hasEntitlement` (cached per request, never cached across requests longer than 60 seconds).

## 2. Catalogue

- **Product:** something we sell. `key` examples: `premium_monthly`, `premium_annual`, `vip_monthly`, `credits_pack_small`, `masterclass_rejection`, `session_mia_60`, `retreat_2027_spring`.
- **Price:** a product's price on a channel (`app_store`, `play_store`, `web`) in a country or region and currency. The same product can cost less on the web than in the app; this is expected (F-082).
- **Entitlement:** a named capability. Examples: `premium`, `vip`, `ai_monthly_credits`, `masterclass:rejection`, `coach_messaging`.
- **Product entitlements:** what each product grants and in what quantity (for example `vip_monthly` grants `premium`, `vip`, and 2,000 `ai_monthly_credits` per period).

Tier contents (which features are Free, Premium, VIP) are configuration in `packages/shared/src/tiers.ts` plus the catalogue tables, not scattered `if` statements. (Open question: final tier contents and prices.)

## 3. Grant sources

| Source | How a grant is created | How it ends |
|---|---|---|
| App Store / Google Play subscription | RevenueCat webhook (`INITIAL_PURCHASE`, `RENEWAL`, `PRODUCT_CHANGE`, `UNCANCELLATION`) | `EXPIRATION`, `REFUND` webhooks; `ends_at` = period end + grace period |
| Web subscription | Stripe webhooks (`checkout.session.completed`, `customer.subscription.*`, `invoice.paid`) | `customer.subscription.deleted`, refunds |
| One-off purchase | Stripe or RevenueCat non-subscription purchase webhook | Refund |
| Trial | Store or Stripe trial, via the same webhooks | Trial end without conversion |
| Admin | Admin console action (audited) | Admin revocation or set end date |
| Referral reward | `billing.referral.rewarded` handler | Fixed duration |
| Promo code | Redemption endpoint | Fixed duration |

RevenueCat is also told about Stripe purchases (RevenueCat's Stripe integration), so RevenueCat's dashboard and SDK show the complete subscription picture on every platform. Our database remains the source of truth for in-app access checks.

## 4. Webhook handling rules

1. Verify the signature (RevenueCat authorization header, Stripe signing secret). Reject if invalid.
2. Insert into `billing.webhook_events` with the provider's event ID (unique). If it already exists, return 200 and stop.
3. Return 200 quickly; process in a job.
4. Processing fetches the **current** state from the provider API (RevenueCat customer info or Stripe subscription) rather than trusting the event's snapshot. This makes out-of-order delivery harmless.
5. Reconcile grants to match the current state. Publish events.
6. A nightly reconciliation job compares active subscriptions with both providers and alerts on any mismatch.

## 5. Purchase routes and store rules

- In the mobile app, digital goods (subscriptions, credits, masterclasses) are sold through in-app purchase via RevenueCat.
- Whether the app may also show a link or button to buy on the web at a lower price depends on the storefront country and the store's current rules, which have changed several times (for example, US App Store rules on external purchase links changed in 2025; EU rules differ under the Digital Markets Act). **Never hard-code this.** `GET /v1/app-config` returns, per user country and platform, which purchase routes the app may show. A human verifies the current store rules before each phase launch and updates the config.
- Physical or in-person services (1:1 coaching calls with a human, in-person events and retreats) can generally be paid outside in-app purchase. Confirm against current guidelines before launch and record the conclusion in an ADR.
- Users who buy on the web sign in with the same account in the app and get access immediately.

## 6. Credits (AI usage)

Credits are an internal currency for AI usage (F-036). 1 credit is a fixed amount of AI cost (the exact rate is configuration, for example 1 credit = £0.001 of provider cost at list price; open question to confirm). Users see simple numbers, not tokens.

### 6.1 Ledger
- `billing.credit_ledger` is append-only. Balance = sum of `delta` for rows not expired.
- Reasons: `monthly_allowance`, `top_up`, `ai_usage`, `reservation`, `reservation_release`, `refund`, `admin_adjustment`, `referral_reward`, `expiry`.
- Monthly allowance credits expire at the end of the period. Purchased top-up credits expire after 12 months (open question to confirm). Spending uses the soonest-expiring credits first.

### 6.2 Spending flow
1. AI module estimates the maximum cost of the request (from input size and a capped output length).
2. `reserveCredits(userId, estimate, ref)` locks the user's `credit_wallets` row (`SELECT ... FOR UPDATE`), checks the balance, inserts a negative `reservation` row, commits. If the balance is too low it returns `INSUFFICIENT_CREDITS` and the app shows the top-up or upgrade sheet.
3. The AI call runs.
4. `settleCredits(reservationId, actual)` inserts a `reservation_release` for the estimate and an `ai_usage` row for the actual cost, in one transaction.
5. If the call fails, `releaseCredits` returns the full reservation.
6. A job releases reservations older than 10 minutes that were never settled (crash safety).

### 6.3 Limits
- Per-user daily hard cap on credits spent (abuse protection), configurable per tier.
- Global hourly AI spend alert and an automatic circuit breaker at a configurable ceiling.
- `billing.credits.low` published at 20% of monthly allowance remaining.

## 7. Referrals (F-084)
- Each member has a referral code and share link.
- A referral counts when the referred person signs up with the code **and** completes their first paid period (prevents abuse).
- Reward: configurable (for example, one free month of Premium as an admin-style grant, or a Stripe coupon for web subscribers). Store subscriptions cannot be extended by us directly, so app-store subscribers receive the reward as an entitlement grant that layers on top. Exact mechanics confirmed before Phase 2.

## 8. Coach payouts (F-091)
- Coaches onboard to Stripe Connect Express from the coach portal (identity verification handled by Stripe).
- When `bookings.session.completed` fires, billing records a `payout_items` row: gross, platform fee (commission rate per coach, configurable), net.
- Payouts run on a schedule (for example weekly) as Stripe transfers. Cancellations and refunds follow the policy in the bookings spec (to be written in P2-M5) and create negative adjustments rather than editing rows.
- Mia's own sessions do not create payouts unless configured.

## 9. Refunds
- App Store refunds are decided by Apple; we react to the webhook (revoke grants, claw back unused credits from that purchase).
- Google Play and Stripe refunds can be issued by admins from the console (audited), then processed through the same webhook path.

## 10. Testing requirements
- 90%+ line coverage in `modules/billing`.
- Recorded webhook fixtures for every event type handled, including out-of-order and duplicate delivery.
- Concurrency tests for credit reservations.
- End-to-end sandbox purchase tests on iOS, Android and web before each phase launch.
