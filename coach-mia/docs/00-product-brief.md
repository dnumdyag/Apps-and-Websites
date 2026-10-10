# 00. Product Brief

Source: the stakeholder document "Coach Mia sum up". That document is semi-final. This brief interprets it into buildable scope. Where an interpretation was needed, it is marked **(interpretation)** and, if it matters, logged in `OPEN-QUESTIONS.md`.

## 1. Product in one sentence

A premium, ethical coaching app that helps single men (and later, men in relationships) build confidence, date well and form healthy long-term relationships, through structured lessons, a personal AI coach trained on Mia's methods, live coaching with real coaches, and a supportive community.

## 2. Positioning and principles

These come straight from the brief's SWOT conclusion and shape every product decision.

1. **Feels like a personal coach, not a content library.** Personalisation is the core experience.
2. **Ethical and healthy.** Long-term relationship success, never manipulation or "pickup" tactics. The AI and community must enforce this (reputation risk is a named threat).
3. **Hybrid.** Self-paced learning plus interactive coaching (AI and human).
4. **Engagement through action.** Challenges, habits and real-world steps, not passive watching.
5. **Simple and clean.** Minimal steps, no clutter, mobile first.
6. **Trust and privacy.** Users share very personal material. Privacy is a feature.

## 3. Users and roles

| Role | Who | Main surfaces |
|---|---|---|
| Guest | Exploring before signing up | Mobile, web |
| Member (Free) | Signed up, not paying | Mobile, web |
| Member (Premium / VIP) | Paying subscriber | Mobile, web |
| Coach | Guest coaches who run 1:1 and group sessions | Coach portal (web), mobile |
| Senior coach | Mia herself: coach plus content owner | Coach portal, admin |
| Moderator | Monitors community | Admin console |
| Admin | Runs the business: content, users, refunds, credits, events | Admin console |
| Partner venue (later) | Restaurants, bars, coffee shops recommended for dates | Partner pages, limited portal |

Target audience at launch: single men aged 18+. Later: men in relationships (relationship track, F-105).

## 4. Feature catalogue

Every feature has a stable ID. Code, tasks, tests and analytics refer to these IDs. Never renumber; deprecate instead.

Phase: **1** = MVP, **2** = Growth, **3** = Full platform. See `04-build-plan.md`.

### Onboarding and identity
| ID | Feature | Phase | Notes |
|---|---|---|---|
| F-001 | Sign-up with email, Apple, Google | 1 | Apple sign-in is mandatory on iOS if any social login is offered. Minimal fields: name, email, age confirmation (18+), relationship status |
| F-002 | Guest mode | 1 | Browse limited content before sign-up. Guest data migrates to the account on sign-up |
| F-003 | Welcome flow with Mia video | 1 | Short video, explains the app |
| F-004 | Coaching goal selection | 1 | e.g. confidence, attracting the right partner, communication |
| F-005 | Initial assessment quiz | 1 | Short, fun, drives the roadmap |
| F-006 | Guided tour | 1 | Skippable, revisitable from settings |
| F-007 | First action step (quick win) | 1 | Immediately after onboarding |
| F-008 | Contextual notification permission prompt | 1 | Ask after first win, not on launch |
| F-009 | Profile completion prompts | 1 | |
| F-064 | Onboarding progress bar | 1 | "You're 20% done" |

### Learning content
| ID | Feature | Phase | Notes |
|---|---|---|---|
| F-010 | Video lessons | 1 | Streamed via Mux, offline download later |
| F-011 | Audio lessons and podcasts | 1 | Background playback, lock-screen controls |
| F-012 | Written guides and playbooks | 1 | Markdown in app, PDF download for premium |
| F-013 | Quizzes and assessments (including attachment style test) | 1 (basic), 2 (attachment) | |
| F-014 | Netflix-style browsing by collection | 1 | e.g. "Confidence Boosters", "First Date Strategies" |
| F-015 | Continue watching and resume position | 1 | |
| F-016 | Mark as completed | 1 | Feeds progress and gamification |
| F-017 | Conversation starters and scripts library | 2 | |
| F-018 | Masterclasses (premium or one-off purchase) | 2 | |
| F-019 | Meditations and affirmations | 2 | Audio content type |

### Coaching path and self-work
| ID | Feature | Phase | Notes |
|---|---|---|---|
| F-020 | Personalised roadmap | 1 | Generated from assessment and goals, re-ranked by progress |
| F-021 | Progress tracking and levels | 1 | |
| F-022 | Weekly progress report with AI insights | 2 | |
| F-023 | Journaling and reflection | 2 | Private by default, encrypted |
| F-024 | Habit tracker | 2 | |
| F-025 | Inner work and self-worth exercises | 2 | Content plus journaling prompts |

### Coach Mia AI
| ID | Feature | Phase | Notes |
|---|---|---|---|
| F-030 | Coach Mia AI chat | 1 | Answers in Mia's voice from Mia's content. Spec: `specs/ai-coach.md` |
| F-031 | Conversation screenshot analysis | 2 | Upload chat screenshots for feedback |
| F-032 | Dating profile screenshot analysis | 2 | Tinder, Bumble, Hinge profiles |
| F-033 | Message breakdown (pasted text) | 1 | Cheaper than screenshots, same feedback |
| F-034 | Date planner and post-date review | 3 | |
| F-035 | Urgent support (breakup, rejection) with crisis safeguards | 1 | Must route genuine distress to real help |
| F-036 | AI credits allowance and top-ups | 1 | Spec: `specs/billing-and-entitlements.md` |

### Live coaching
| ID | Feature | Phase | Notes |
|---|---|---|---|
| F-040 | Book 1:1 session with Mia | 1 | Paid per session or included in VIP |
| F-041 | Guest coaches and booking | 2 | Mia's diary is limited, guest coaches meet demand |
| F-042 | Group coaching calls | 2 | |
| F-043 | Live Q&A webinars | 3 | |
| F-044 | Direct messaging with coaches | 3 | Premium feature |
| F-045 | In-app video calls | 1 | Used by F-040 onward |
| F-046 | Payment links for sessions and retreats | 1 | Web checkout links shareable by admin |

### Community
| ID | Feature | Phase | Notes |
|---|---|---|---|
| F-050 | Themed discussion groups | 2 | Confidence, breakups, online dating |
| F-051 | Success stories and wins | 2 | |
| F-052 | Peer Q&A | 2 | |
| F-053 | Peer accountability groups | 3 | Small groups |
| F-054 | Anonymous mode | 2 | Pseudonymous posting, never fully untraceable to admins |
| F-055 | Moderation: AI pre-screen, reports, human queue, sanctions | 2 | Must exist before community launches |

### Challenges and gamification
| ID | Feature | Phase | Notes |
|---|---|---|---|
| F-060 | Daily and weekly challenges | 1 (daily tip), 2 (full) | |
| F-061 | Streaks | 1 | |
| F-062 | Achievements and badges | 1 (core set), 2 (full) | Includes self-reported real-life wins |
| F-063 | Leaderboards | 3 | Opt-in only |

### Events and partners
| ID | Feature | Phase | Notes |
|---|---|---|---|
| F-070 | Exclusive member events (sports, drinks, cigars, interest groups, networking) | 3 | Ticketed |
| F-071 | In-person retreats and workshops | 3 | High ticket, web checkout |
| F-072 | Partner venues for first dates | 3 | (interpretation) Listings first, partner portal later |

### Monetisation and growth
| ID | Feature | Phase | Notes |
|---|---|---|---|
| F-080 | Tiers: Free, Premium, VIP | 1 | Exact tier contents are an open question |
| F-081 | Free trial | 1 | |
| F-082 | Web checkout at lower price plus in-app purchase | 1 | Spec: `specs/billing-and-entitlements.md` |
| F-083 | One-time purchases (masterclasses, session packs) | 2 | |
| F-084 | Referrals (free month or discount) | 2 | |
| F-085 | Welcome bonus and promo codes | 2 | |
| F-086 | Paywalls and upsell moments | 1 | |

### Coach marketplace
| ID | Feature | Phase | Notes |
|---|---|---|---|
| F-090 | Coach portal: availability, sessions, earnings, notes | 1 (Mia), 2 (guests) | |
| F-091 | Coach payouts via Stripe Connect | 2 | |
| F-092 | Member-to-coach pathway (eligible after 12 months of consistent use, apply, train, get paid) | 3 | |

### Platform
| ID | Feature | Phase | Notes |
|---|---|---|---|
| F-100 | Push notifications, reminders, check-ins | 1 | |
| F-101 | Transactional and lifecycle email | 1 | |
| F-102 | Admin console: users, content, credits, refunds, moderation, events | 1 (core), 2+ | |
| F-103 | Product analytics and A/B testing | 1 | |
| F-104 | Localisation (multiple languages) | 3 | i18n structure from day 1 |
| F-105 | Relationship track for men in relationships | 3 | |
| F-106 | Account deletion and data export | 1 | Legal requirement (App Store and GDPR) |
| F-107 | Corporate partnerships | Later | Not designed yet |

## 5. Key flows

1. **First run:** Welcome → sign-up (or guest) → goals → assessment → personalised dashboard → first action → notification prompt.
2. **Daily loop:** Open app → daily tip or challenge → continue lesson → maybe ask Coach Mia AI → streak updated.
3. **Get help with a real situation:** Paste text or upload screenshot → AI feedback (uses credits) → suggested lesson → option to book a coach.
4. **Book a coach:** Choose coach → choose slot (in user's time zone) → pay or use entitlement → confirmation and calendar invite → reminder → in-app call → post-session notes and review.
5. **Upgrade:** Hit a paywall moment → see tiers → buy in app, or follow the web link where the law and store rules allow → entitlement active on all devices within seconds.
6. **Community (Phase 2):** Browse groups → post (optionally anonymous) → AI pre-screen → visible → replies notify.

## 6. Success metrics

| Metric | Why |
|---|---|
| Onboarding completion rate | First experience matters most |
| Day 1, 7, 30 retention | Retention is a named weakness and threat |
| Weekly active learners | Engagement |
| Free to paid conversion | Revenue |
| Paid churn per month | Churn is a named threat |
| AI cost per paying user per month vs. revenue per user | AI cost control |
| Crash-free sessions (target 99.5% or better) | Technical issues are a named threat |
| Session booking utilisation per coach | Coaching capacity |

## 7. Out of scope until decided

- A dating or matchmaking feature between members (the brief mentions "matchmaking" once in passing; treated as out of scope).
- Women as members.
- Native desktop apps.
