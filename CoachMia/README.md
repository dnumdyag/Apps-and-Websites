# Coach Mia (iOS MVP)

Native SwiftUI iPhone app, styled to match the "Coach Mia App" design canvas (mint and deep green, gold accents, Cormorant Garamond and Montserrat) and built from the Coach Mia feature brief. No third-party dependencies.

## Run it

1. Open `CoachMia/CoachMia.xcodeproj` in Xcode 16 or newer.
2. Pick an iPhone simulator (iPhone 15/16/17) and press Run (Cmd+R).
3. To run on a real iPhone: select the `CoachMia` target > Signing & Capabilities > choose your Team. Change the bundle id (`com.coachmia.app`) if Xcode says it's taken.

## Turn on the real AI coach (optional)

Out of the box, Mia replies with built-in demo answers so the app works offline.
For live answers (and real screenshot feedback), either:

- paste an Anthropic API key into `CoachMia/Config.swift` (`anthropicAPIKey`), or
- in the app: Home > tap your avatar (top right) > Settings > Coach Mia AI > paste the key.

The app calls Claude directly from the phone. That's fine for a demo, but for the App Store build the call must move to a small backend so the key isn't in the app.

## What's in the MVP

| Area | What works |
| --- | --- |
| Onboarding | Sign-up screen, name/age/status, goals, biggest challenge, personalised first module, 7-day trial |
| Home | Message from Mia, daily challenge + streak, learning path progress, next live session, upcoming 1:1, reflections |
| Mia (AI coach) | Chat, quick prompts, upload a screenshot of texts or a dating profile for feedback, free monthly message allowance (30) with upgrade prompt |
| Journey | 8 module timeline, video lesson (sample video), key takeaways, exercise, mark complete, locked modules, "Ask Mia about this". Below it: membership, book a 1:1 with Mia or a guest coach, retreats |
| Community | Join groups, group feed, post (optionally anonymously), like, report to moderators |
| Sessions | Live sessions/webinars/group Q&A (reserve), exclusive in-person member events filtered by theme (sports, drinks, cigars, networking, social), recordings player |
| Profile (avatar on Home) | Photo, blind spot from the quiz, stats, about you, groups, membership, referral code + share, "become a coach" progress, settings, sign out (resets the demo) |

Everything is saved on the device (UserDefaults). Payments, sign-in with Apple/Google and push notifications are simulated. They are the next things to wire up after the customer demo.

## Where to change things

- Colours and fonts: `Theme.swift` (fonts are bundled in `Fonts/`, OFL licensed)
- Photos: `Assets.xcassets` (`mia_hero`, `mia_avatar`, `coach_*`, `retreat_*`)
- All demo copy (modules, groups, events, coaches, prices): `MockData.swift`
- Mia's personality / AI rules: `MiaAI.swift` (`systemPrompt`)
- Currency, support email, website: `Config.swift`

## Build check

Every push that touches `CoachMia/` is compiled on a Mac by GitHub Actions (`.github/workflows/ios-build.yml`), which also saves simulator screenshots of each tab as a downloadable "screenshots" artifact on the run.
