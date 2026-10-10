# 05. Launch Readiness

"Ready to launch" is not a feeling. It is this checklist, fully green. It applies to the Phase 1 launch and to every phase release after it. Work through it continuously, not in the last week: most items are built into earlier milestones.

## 1. Release gates (every production release)

- [ ] CI fully green on the release commit, including integration tests and contract check.
- [ ] Migrations tested against a copy of the production schema; backward compatible with the previous app and API version.
- [ ] Staging smoke tests pass (Playwright and Maestro critical journeys).
- [ ] No open P0 or P1 bugs. P2 bugs reviewed and accepted by a human.
- [ ] Rollback plan known: previous container image, previous OTA update, feature flags to switch off.
- [ ] Changelog written.
- [ ] Monitoring dashboards and alerts cover every new feature.

## 2. Functional readiness (phase launches)

- [ ] Every feature in the phase meets its catalogue entry and milestone exit criteria.
- [ ] Every critical journey tested on real devices: small and large iPhone, iPad (if supported), low-end and high-end Android, slow network, airplane mode, interrupted purchase, app killed mid-flow.
- [ ] Purchases tested end to end in sandbox on iOS, Android and web, including trial, upgrade, downgrade, cancel, expiry, refund, billing retry, restore, family sharing (if enabled), and account linking.
- [ ] Time zone and daylight-saving cases tested for bookings, streaks and notifications.
- [ ] Deep links and universal links work from email, push and web.

## 3. Quality and performance

- [ ] Performance budgets in standards section 7 met on staging.
- [ ] Load test at 10x expected launch traffic passes with p95 within budget and no errors.
- [ ] AI load test: concurrent chats at expected peak, credit ledger stays consistent.
- [ ] Crash-free sessions 99.5%+ across the final beta week.
- [ ] Accessibility pass: VoiceOver, TalkBack, largest text size, contrast check, Reduce Motion.

## 4. Security and privacy

- [ ] Security review of new endpoints against the checklist in standards section 10.
- [ ] Third-party penetration test before the Phase 1 launch and annually after.
- [ ] Dependency audit clean (no high or critical vulnerabilities).
- [ ] Secrets rotated from any value ever used in development.
- [ ] Privacy policy and terms published and linked in app and stores.
- [ ] App Store privacy nutrition labels and Google Play data safety form match actual data collection.
- [ ] iOS privacy manifest complete.
- [ ] Account deletion works in app (store requirement) and actually deletes data per the retention table.
- [ ] Data export works.
- [ ] Data processing agreements in place with every vendor that handles personal data.
- [ ] Records of processing and a data protection impact assessment completed (screenshots and AI processing are high-risk processing).

## 5. AI safety

- [ ] Eval suite passes all thresholds in `specs/ai-coach.md`.
- [ ] Crisis routing tested by humans with realistic scenarios, with resources correct for each launch country.
- [ ] Red-team session completed: attempts to get manipulative, harmful, sexual, or unethical advice; prompt injection through screenshots and pasted text.
- [ ] AI spend alerts configured; hard daily spend cap per user and globally.
- [ ] Clear in-app disclosure that Coach Mia AI is an AI and not therapy.

## 6. Store readiness

- [ ] App Store Review Guidelines checked: in-app purchase rules for digital content, external purchase link rules for each launch storefront, sign in with Apple, account deletion, user-generated content requirements (reporting, blocking, moderation) when community launches, age rating.
- [ ] Google Play policies checked: payments, user data, user-generated content, age rating.
- [ ] Store listings: screenshots, preview video, description, keywords, support URL, privacy URL.
- [ ] Review notes and a demo account for store reviewers (with premium access).

## 7. Operations

- [ ] On-call rota and escalation path agreed (even if it is two people).
- [ ] Runbooks tested: deploy, rollback, restore, rotate secret, payment incident, AI cost spike, safety incident, data deletion.
- [ ] Database restore drill done within the last 30 days.
- [ ] Status page or a plan for communicating outages.
- [ ] Support inbox and process for refunds, account issues and safety reports.

## 8. Business readiness

- [ ] Pricing and tiers confirmed (see `OPEN-QUESTIONS.md`).
- [ ] Launch content library loaded and reviewed by Mia.
- [ ] Coach Mia AI knowledge base reviewed by Mia; sample answers signed off.
- [ ] Moderator(s) trained (Phase 2).
- [ ] Analytics dashboards for the success metrics live.
