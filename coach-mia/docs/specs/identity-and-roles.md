# Spec: Identity and Roles

## 1. Accounts

- One account per person, keyed by our `identity.users.id` (UUIDv7). The auth provider's user ID is stored in `auth_provider_id` and never used as our primary key, so the auth provider can change.
- Sign-in methods: Sign in with Apple, Google, email (magic link and password). Passkeys later. If any social login is offered on iOS, Sign in with Apple must also be offered.
- Account linking: the same verified email across providers links to the same account. Apple "hide my email" relay addresses are treated as distinct unless the user links them in settings.
- Age gate: members must confirm they are 18 or over. Store `age_confirmed_at`. (Open question: whether to collect date of birth.)
- Guest mode: a guest gets an anonymous auth session and a `users` row with `status = guest`. On sign-up the same row is upgraded, so progress carries over. Guests cannot purchase, chat with AI beyond a small free sample, or post in community.
- The `users` row is created on the first authenticated API call (`GET /v1/me`), idempotently.

## 2. Roles

| Role | Granted by | Can do (summary) |
|---|---|---|
| `member` | Automatically on sign-up | Use the member app according to entitlements |
| `coach` | Admin (or the member-to-coach pathway in Phase 3) | Manage own availability, sessions, notes, earnings |
| `senior_coach` | Admin | Everything a coach can, plus publish content and review AI knowledge |
| `moderator` | Admin | Review reports, hide or remove posts, apply sanctions up to suspension |
| `admin` | Another admin | Everything, including role management, refunds and credit adjustments |
| `partner` | Admin | Manage their own venue listing (Phase 3) |

A user can hold several roles at once. Mia holds `member`, `senior_coach` and `admin`. A member who becomes a coach keeps `member`.

Roles are not entitlements. "Premium" is an entitlement (paid access), not a role.

## 3. Permissions

- Permissions are string constants in `packages/shared/src/permissions.ts`, named `<resource>:<action>` or `<resource>:<action>:<scope>`. Examples: `content:read`, `content:publish`, `booking:create`, `booking:manage:own`, `booking:manage:any`, `community:moderate`, `credits:adjust`, `roles:assign`, `ai:knowledge:manage`, `audit:read`.
- The role-to-permission map lives in the same file and is the only place it is defined. Clients import it to decide what to show; the API enforces it.
- Every API route declares exactly one required permission in its contract metadata. The permission guard rejects with `403 FORBIDDEN` if the user lacks it. Routes without a declared permission fail a CI check, except routes explicitly marked `public`.
- **Ownership** is checked in the service layer for any `:own` permission: the resource's `user_id` or `coach_id` must match the caller.
- Sanctions (from community) are checked by the permission guard: a suspended user loses write permissions in community; a banned user is signed out everywhere.

## 4. Admin safety

- Role grants and revocations, credit adjustments, refunds, sanctions and content deletions are written to `admin.audit_log` with before and after values.
- Admins cannot remove their own `admin` role (prevents lock-out) and at least two admins must exist in production.
- Admin console sessions require multi-factor authentication. (Supabase Auth MFA or enforced through the identity provider.)
- "View as user" (impersonation) is read-only and audited.

## 5. Account deletion and export (F-106)

1. User requests deletion in app or on web. They are told what happens and that there is a 30-day grace period.
2. `identity.deletion.requested` is published; the account is signed out and marked pending deletion. Active subscriptions: the user is shown how to cancel store subscriptions (we cannot cancel App Store subscriptions on their behalf) and web subscriptions are cancelled automatically.
3. After the grace period, a job publishes `identity.deletion.executing`. Every module that stores personal data implements `eraseUser(userId)`: hard delete or anonymise, per the retention table in `03-data-model.md`.
4. The orchestrator confirms every module reported success, then deletes the auth provider record and the `users` row (financial records keep a pseudonymous ID).
5. Data export produces a machine-readable archive of the user's data from every module's `exportUser(userId)` within 30 days of request.

A module that adds personal data and does not implement `eraseUser` and `exportUser` fails review.
