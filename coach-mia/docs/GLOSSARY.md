# Glossary

Use these words exactly. If code or docs use a different word for the same thing, rename it.

| Term | Meaning | Not to be confused with |
|---|---|---|
| **User** | Any account in `identity.users`, whatever its roles | Member |
| **Member** | A user with the `member` role using the coaching app | Coach, admin |
| **Guest** | A user with `status = guest` who has not signed up yet | Free member |
| **Free / Premium / VIP** | Tiers, defined by which entitlements a member holds | Roles |
| **Role** | What a user is allowed to *do* in the system (member, coach, senior_coach, moderator, admin, partner) | Entitlement |
| **Permission** | A named action a role allows, like `booking:manage:own` | Entitlement |
| **Entitlement** | What a user has *paid for or been granted*, like `premium` or `masterclass:rejection` | Role, permission |
| **Grant** | A row giving a user an entitlement for a period, from a source (store, Stripe, admin, referral, promo, trial) | Purchase |
| **Product** | Something we sell, like `premium_monthly` | Price |
| **Price** | What a product costs on a channel in a country | Product |
| **Channel** | Where a purchase happens: `app_store`, `play_store`, `web` | Platform |
| **Credits** | Internal units that pay for AI usage | Points |
| **Points** | Gamification score, no monetary value | Credits |
| **Ledger** | Append-only table of changes (credits, points, audit); balances are sums | Balance column |
| **Reservation** | Credits held before an AI call, settled after | Booking hold |
| **Lesson** | One piece of learning content (video, audio, guide, quiz, exercise, meditation, script) | Course |
| **Course** | An ordered set of lessons | Collection |
| **Collection** | A browsing row of lessons or courses ("First Date Strategies") | Course |
| **Roadmap** | A member's personalised ordered path of steps | Course |
| **Challenge** | A real-world task to complete (daily, weekly or one-off) | Habit |
| **Habit** | A recurring self-chosen behaviour the member tracks | Challenge |
| **Streak** | Consecutive local days with qualifying activity | |
| **Coach** | A user with the `coach` role who runs sessions | Coach Mia AI |
| **Senior coach** | Mia's role: coach plus content and AI knowledge owner | Admin |
| **Coach Mia AI** | The AI coach feature | Mia (the person) |
| **Session** | A live coaching call (1:1 or group) | Auth session, app session |
| **Booking** | A member's reservation of a session slot | Session |
| **Hold** | A temporary booking reservation awaiting payment | Reservation (credits) |
| **Event** | A member event, retreat or workshop (module `events`) | Domain event |
| **Domain event** | An internal message like `content.lesson.completed` | Event (member event), analytics event |
| **Analytics event** | A tracking event sent to PostHog | Domain event |
| **Module** | A bounded area of the API with its own schema and interface | Package |
| **Package** | A shared code library in `packages/` | Module |
| **Contract** | The typed definition of an API endpoint in `packages/contracts` | |
| **Adapter** | Our interface around a third-party service | |
| **Knowledge base** | Mia's content prepared for AI retrieval | Content library |
| **Analysis** | An AI review of pasted text or screenshots | Chat |
| **Tier (AI)** | `coach`, `vision`, `fast`, `batch`: which model configuration a feature uses | Tier (subscription) |
| **Flag** | A feature flag controlling who sees a feature | Report (community) |
| **Report** | A member reporting a post or comment | Weekly report |
| **Sanction** | A moderation penalty (warning, mute, suspension, ban) | |
