# Dave the COACH Flutter Supabase App v1 Implementation Plan

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task.

**Goal:** Turn the Flutter showcase into a real athlete/coach app with Supabase auth, private athlete data, weekly check-ins, and Dave reporting hooks.

**Architecture:** Keep the Flutter app as a public installable shell, but move all private data flows behind Supabase auth and row-level security. Use `go_router` for app flows, `supabase_flutter` for auth/data access, repository-style service classes for business logic, and a lightweight HTTP reporting service for Dave webhook notifications.

**Tech Stack:** Flutter, `supabase_flutter`, `go_router`, `http`, `intl`, `uuid`, Supabase Auth, Postgres, RLS.

---

### Task 1: Add runtime config and Supabase bootstrap

**Objective:** Make the app read deploy-time configuration for Supabase and Dave reporting.

**Files:**
- Create: `lib/core/app_config.dart`
- Create: `lib/core/app_bootstrap.dart`
- Modify: `lib/main.dart`

**Implementation notes:**
- Read these keys with `String.fromEnvironment`:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
  - `DAVE_WEBHOOK_URL`
  - `DAVE_WEBHOOK_SECRET`
- Add booleans for whether Supabase and reporting are configured.
- Initialize `Supabase.initialize()` before app start.
- If config is missing, keep the app runnable but show a setup-required state rather than fake private auth.

**Verification:**
- `flutter test`
- `flutter build web --release --base-href /dave-the-coach-flutter/`

### Task 2: Create app domain models

**Objective:** Add typed models for auth state, athlete profiles, and check-ins.

**Files:**
- Create: `lib/features/auth/domain/app_user_role.dart`
- Create: `lib/features/auth/domain/app_session.dart`
- Create: `lib/features/athletes/domain/athlete_profile.dart`
- Create: `lib/features/checkins/domain/weekly_checkin.dart`

**Implementation notes:**
- Model `athlete` and `coach` roles.
- Keep JSON parsing explicit and predictable.
- Weekly check-ins should include bodyweight, sleep, recovery, notes, created_at, and athlete id.

**Verification:**
- Add/extend widget or unit tests as parsing helpers are introduced.

### Task 3: Add repositories/services for auth, profiles, check-ins, and reporting

**Objective:** Separate UI from Supabase and webhook logic.

**Files:**
- Create: `lib/features/auth/data/auth_repository.dart`
- Create: `lib/features/athletes/data/athlete_repository.dart`
- Create: `lib/features/checkins/data/checkin_repository.dart`
- Create: `lib/features/reporting/data/dave_reporting_service.dart`

**Implementation notes:**
- `AuthRepository` handles sign up, sign in, sign out, current session, and auth stream.
- `AthleteRepository` loads current profile and coach-visible roster.
- `CheckinRepository` lists and upserts athlete weekly check-ins.
- `DaveReportingService` POSTs compact event payloads when check-ins are saved, but no-op cleanly if reporting config is absent.

**Verification:**
- `flutter analyze` if clean enough, otherwise `flutter test` + `flutter build web`.

### Task 4: Build login, signup, auth gate, and route protection

**Objective:** Replace the one-page showcase shell with a real app flow.

**Files:**
- Create: `lib/app/app_router.dart`
- Create: `lib/features/auth/presentation/login_screen.dart`
- Create: `lib/features/auth/presentation/signup_screen.dart`
- Create: `lib/features/auth/presentation/auth_gate.dart`
- Modify: `lib/main.dart`

**Implementation notes:**
- Public route: marketing/showcase entry.
- Protected routes: athlete dashboard and coach dashboard.
- Redirect unauthenticated users to login.
- Redirect authenticated users by role.
- Show configuration warning if Supabase keys are absent.

**Verification:**
- Widget test for app boot to auth entry.
- Browser smoke test after `flutter build web`.

### Task 5: Build athlete profile and weekly check-in screens

**Objective:** Give athletes a real private surface.

**Files:**
- Create: `lib/features/athletes/presentation/athlete_dashboard_screen.dart`
- Create: `lib/features/checkins/presentation/checkin_form_card.dart`
- Create: `lib/features/checkins/presentation/checkin_history_card.dart`

**Implementation notes:**
- Show athlete profile summary.
- Allow entry/edit of weekly bodyweight, sleep hours, recovery score, notes.
- Save to Supabase and refresh list.
- Trigger reporting service after save.

**Verification:**
- Widget test for form presence.
- Manual web verification after build.

### Task 6: Build coach roster view

**Objective:** Give Dave a private coach command surface.

**Files:**
- Create: `lib/features/coach/presentation/coach_dashboard_screen.dart`

**Implementation notes:**
- Show roster, athlete summaries, and most recent check-in snapshots.
- Limit coach-only data based on role from profile.
- Keep UI consistent with the futuristic energetic visual direction.

**Verification:**
- Manual smoke verification in web build.

### Task 7: Add Supabase SQL bootstrap artifacts

**Objective:** Define the backend schema and RLS needed for private athlete data.

**Files:**
- Create: `supabase/migrations/0001_profiles_and_checkins.sql`
- Create: `docs/setup/supabase.md`

**Implementation notes:**
- Tables:
  - `profiles`
  - `athlete_profiles`
  - `weekly_checkins`
- Policies:
  - athletes can view/update only their own profile/check-ins
  - coaches can view athletes assigned to them
- Document required auth metadata or role strategy.

**Verification:**
- Review SQL for role coverage.
- Ensure Flutter field names match SQL columns.

### Task 8: Update deployment docs for public launch

**Objective:** Explain how to run this app publicly with real backend credentials.

**Files:**
- Modify: `README.md`
- Modify: `.github/workflows/deploy-pages.yml`

**Implementation notes:**
- Pass `--dart-define` variables from GitHub Actions secrets or variables.
- Document that the public URL is the GitHub Pages URL.
- Note that auth/data stay private because Supabase enforces access, even though the web app itself is publicly reachable.

**Verification:**
- Rebuild and push.
- Confirm Pages still returns HTTP 200.
