# Abdo / Dave Multi-User Coach Dashboard SaaS Implementation Plan

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task.

**Goal:** Turn the current single-user static workout page into a secure multi-user coaching SaaS where each athlete has a private dashboard, Dave can create and update customized plans, and athlete updates are automatically reported back to Dave.

**Architecture:** Replace the static-only model with a full-stack web app using Supabase for auth, database, storage, and row-level security; a server-rendered app layer for protected pages and APIs; and a Hermes-backed webhook/reporting service that relays athlete updates to Dave on Telegram. Keep the current premium dashboard styling, but move all mutable state out of browser localStorage and into the database.

**Tech Stack:** Next.js 15+, TypeScript, Tailwind CSS, Supabase Auth, Supabase Postgres, Supabase Storage, Supabase Edge Functions or server actions, Telegram/Hermes webhook integration, optional cron jobs for digests/reminders.

---

## Product Direction

### Core roles
- **Athlete user**
  - Signs in securely
  - Sees only their own dashboard
  - Submits check-ins, progress updates, journey photos, body metrics, and workout completion
  - Cannot edit another athlete's data
- **Coach (Dave)**
  - Has coach/admin dashboard
  - Can create a customized plan per athlete
  - Can review athlete updates
  - Can push new plan blocks and coaching notes to athlete dashboards
- **System / Hermes layer**
  - Sends athlete updates to Dave via Telegram
  - Optionally summarizes daily/weekly check-ins
  - Can later generate first-draft plans for Dave to review

### Why option 2 is the right foundation
Supabase is the right "stronger stack" because it solves the hard parts cleanly:
- real login
- per-user private data
- secure database policies
- server-side update APIs
- media/photo storage
- clean future SaaS scaling

The current Netlify static branch deploy is good for design validation, but not enough for:
- private editing
- real user accounts
- coach workflows
- auditable reporting to Dave
- multi-user SaaS billing/growth later

---

## Recommended system architecture

### Frontend app
Move from a single `index.html` static file to a real app, for example:
- `app/(marketing)` for public landing pages
- `app/(auth)` for login/signup/reset password
- `app/(athlete)` for athlete dashboards
- `app/(coach)` for Dave's coach admin area

### Data layer
Use Supabase tables for:
- user profiles
- athlete records
- coach assignments
- workout plans
- workout weeks
- workout days
- workout blocks
- check-ins
- metrics snapshots
- progress journal entries
- journey timeline entries
- delivery logs / notification events

### Reporting path to Dave
Recommended event path:
1. Athlete submits check-in / workout completion / progress note
2. App writes to Supabase
3. DB trigger or app server calls webhook endpoint
4. Hermes webhook or secure API route formats the event
5. Hermes sends message to Dave target on Telegram
6. Event is logged so nothing is silently lost

### Login and permissions
Use Supabase Auth with email magic link or password login.

Minimum access model:
- athlete can read/write only their own records
- coach can read/write assigned athlete records
- admin can manage all records

Enforce with Supabase Row Level Security, not just frontend checks.

---

## Data model (v1)

### `profiles`
- `id uuid primary key` — same as auth user id
- `email text unique`
- `full_name text`
- `role text check in ('athlete','coach','admin')`
- `created_at timestamptz default now()`

### `athletes`
- `id uuid primary key`
- `profile_id uuid references profiles(id)`
- `coach_profile_id uuid references profiles(id)`
- `display_name text`
- `phone text null`
- `goal text`
- `training_level text`
- `injury_notes text`
- `private_notes text null`
- `created_at timestamptz default now()`

### `plans`
- `id uuid primary key`
- `athlete_id uuid references athletes(id)`
- `coach_profile_id uuid references profiles(id)`
- `title text`
- `goal text`
- `status text check in ('draft','active','archived')`
- `version integer default 1`
- `starts_on date null`
- `created_at timestamptz default now()`
- `updated_at timestamptz default now()`

### `plan_weeks`
- `id uuid primary key`
- `plan_id uuid references plans(id)`
- `week_index integer`
- `title text`
- `focus text`
- `sort_order integer`

### `plan_days`
- `id uuid primary key`
- `week_id uuid references plan_weeks(id)`
- `day_index integer`
- `title text`
- `focus text`
- `sort_order integer`

### `plan_blocks`
- `id uuid primary key`
- `day_id uuid references plan_days(id)`
- `title text`
- `sets_label text null`
- `rest_label text null`
- `items jsonb not null`
- `notes jsonb null`
- `sort_order integer`

### `weekly_checkins`
- `id uuid primary key`
- `athlete_id uuid references athletes(id)`
- `week_start date`
- `body_weight_kg numeric(5,2) null`
- `avg_sleep_hours numeric(4,2) null`
- `recovery_score integer null` -- 1 to 10
- `energy_score integer null`
- `stress_score integer null`
- `adherence_score integer null`
- `notes text null`
- `submitted_by uuid references profiles(id)`
- `created_at timestamptz default now()`

### `workout_logs`
- `id uuid primary key`
- `athlete_id uuid references athletes(id)`
- `plan_day_id uuid references plan_days(id)`
- `completed boolean default false`
- `session_rpe integer null`
- `notes text null`
- `performed_at timestamptz null`
- `updated_by uuid references profiles(id)`
- `updated_at timestamptz default now()`

### `progress_snapshots`
- `id uuid primary key`
- `athlete_id uuid references athletes(id)`
- `label text` -- e.g. Week 1 start
- `body_weight_kg numeric(5,2) null`
- `waist_cm numeric(5,2) null`
- `chest_cm numeric(5,2) null`
- `arm_cm numeric(5,2) null`
- `photo_front_path text null`
- `photo_side_path text null`
- `photo_back_path text null`
- `notes text null`
- `created_at timestamptz default now()`

### `timeline_events`
- `id uuid primary key`
- `athlete_id uuid references athletes(id)`
- `event_type text` -- checkin, photo, plan_update, milestone
- `title text`
- `description text null`
- `metadata jsonb null`
- `created_at timestamptz default now()`

### `delivery_events`
- `id uuid primary key`
- `athlete_id uuid references athletes(id)`
- `source_type text` -- checkin, workout_log, progress_snapshot, plan_update
- `source_id uuid`
- `destination text` -- telegram:Workout Plan, telegram:Abdo Eltaweel, etc.
- `status text check in ('queued','sent','failed')`
- `error_text text null`
- `sent_at timestamptz null`
- `created_at timestamptz default now()`

---

## UX scope for v1

### Athlete dashboard
Top sections:
1. **Coach stats header**
   - current weight
   - average sleep
   - recovery score
   - adherence percentage
   - current training phase
2. **Current plan board**
   - week tabs
   - day cards
   - completion toggles
   - notes
3. **Weekly check-in card**
   - weight
   - sleep
   - recovery
   - energy
   - stress
   - short notes
4. **Before / after journey timeline**
   - progress photos
   - milestone entries
   - body metrics snapshots
5. **Coach messages / plan updates**
   - latest note from Dave
   - current plan version

### Coach dashboard (Dave)
1. athlete list
2. athlete health summary cards
3. create/edit plan
4. review incoming check-ins
5. mark note as sent / reviewed
6. push new plan version

---

## Security requirements

### Must-have
- all athlete pages require auth
- all writes happen server-side or through Supabase with RLS
- all sensitive routes verify session user id
- no athlete id accepted blindly from the client
- storage buckets for progress photos must be private
- signed URLs only for authorized users
- audit log for coach-facing updates and outbound deliveries

### Avoid
- localStorage as source of truth
- exposing service-role keys in frontend code
- client-side-only password gates
- public image buckets for body progress photos

---

## Hermes / Dave integration options

### Best v1 implementation
Use a secure app webhook to Hermes:
- Next.js server action or route handler posts normalized event payload to Hermes webhook endpoint
- Hermes validates HMAC secret
- Hermes sends a formatted Telegram message to Dave's destination

Payload example:
```json
{
  "event": "weekly_checkin.submitted",
  "athlete_name": "Abdo",
  "athlete_id": "uuid",
  "weight_kg": 83.4,
  "avg_sleep_hours": 6.7,
  "recovery_score": 8,
  "notes": "Felt stronger on pull day. Left elbow slightly tight.",
  "dashboard_url": "https://app.example.com/coach/athletes/uuid"
}
```

### Message example to Dave
```text
🏋️ Athlete update: Abdo

Weekly check-in submitted
- Weight: 83.4 kg
- Avg sleep: 6.7 h
- Recovery: 8/10
- Energy: 7/10
- Adherence: 90%

Note:
Felt stronger on pull day. Left elbow slightly tight.

Review dashboard:
https://app.example.com/coach/athletes/uuid
```

### Later AI extension
After v1 works, Hermes can also:
- summarize athlete trend changes weekly
- draft next-week plan adjustments for Dave to approve
- detect plateau / sleep / recovery warnings
- auto-create a suggested coach reply draft

But do **not** start there. First ship secure data flow and reliable coach reporting.

---

## Implementation tasks

### Task 1: Create the app shell repo structure

**Objective:** Replace the static-only structure with a proper full-stack app layout while preserving the current design direction as a reference.

**Files:**
- Create: `app/`
- Create: `components/`
- Create: `lib/`
- Create: `supabase/`
- Preserve: `index.html` as design reference only
- Create: `docs/architecture/overview.md`

**Step 1: Initialize Next.js TypeScript app**
Run:
```bash
npx create-next-app@latest . --ts --tailwind --app --eslint --use-npm
```
Expected: app scaffold created

**Step 2: Move current static page into a reference file**
- Rename current `index.html` to `docs/reference/abdo-workout-static-reference.html`
- Do not delete it until parity is reached

**Step 3: Commit**
```bash
git add .
git commit -m "feat: initialize app shell for coach dashboard saas"
```

### Task 2: Add Supabase project configuration

**Objective:** Wire the app to Supabase safely.

**Files:**
- Create: `.env.example`
- Create: `lib/supabase/client.ts`
- Create: `lib/supabase/server.ts`
- Create: `lib/env.ts`

**Step 1: Add env placeholders**
Include:
```env
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
HERMES_WEBHOOK_URL=
HERMES_WEBHOOK_SECRET=
```

**Step 2: Add typed env loader**
Validate required env vars at startup.

**Step 3: Commit**
```bash
git add .env.example lib/
git commit -m "feat: add supabase environment and client setup"
```

### Task 3: Create database schema and RLS policies

**Objective:** Define secure multi-user data ownership.

**Files:**
- Create: `supabase/migrations/0001_initial_schema.sql`
- Create: `supabase/migrations/0002_rls_policies.sql`
- Create: `docs/architecture/data-model.md`

**Step 1: Create tables from the v1 data model**
Use the schema described above.

**Step 2: Enable RLS on all athlete-owned tables**
Add policies so:
- athletes only see their own rows
- coaches see rows tied to assigned athletes
- admins can see all rows

**Step 3: Verify**
Run Supabase local or SQL editor and confirm migrations apply.

**Step 4: Commit**
```bash
git add supabase/migrations docs/architecture/data-model.md
git commit -m "feat: add initial schema and row level security"
```

### Task 4: Implement auth flow

**Objective:** Add secure login so only the right user can edit their dashboard.

**Files:**
- Create: `app/(auth)/login/page.tsx`
- Create: `app/(auth)/signup/page.tsx`
- Create: `middleware.ts`
- Create: `components/auth/login-form.tsx`

**Step 1: Add auth UI**
Build login and signup forms.

**Step 2: Add protected route middleware**
Require auth for athlete and coach app routes.

**Step 3: Verify**
- anonymous user gets redirected to login
- signed-in athlete can access only athlete dashboard

**Step 4: Commit**
```bash
git add app components middleware.ts
git commit -m "feat: add protected auth flow"
```

### Task 5: Build athlete dashboard shell

**Objective:** Recreate the premium athlete experience in the real app.

**Files:**
- Create: `app/(athlete)/dashboard/page.tsx`
- Create: `components/dashboard/coach-stats-header.tsx`
- Create: `components/dashboard/current-plan-board.tsx`
- Create: `components/dashboard/weekly-checkin-card.tsx`
- Create: `components/dashboard/journey-timeline.tsx`

**Step 1: Build responsive page layout**
Use the current dark premium aesthetic as the base.

**Step 2: Add coach stats header**
Show latest metrics and adherence summary.

**Step 3: Add weekly check-in section**
Weight / sleep / recovery / notes form.

**Step 4: Add timeline section**
Render before-after snapshots and milestones.

**Step 5: Commit**
```bash
git add app/(athlete) components/dashboard
git commit -m "feat: build athlete dashboard shell"
```

### Task 6: Persist workout completion and notes to database

**Objective:** Replace browser-only local state with real saved state.

**Files:**
- Create: `app/api/workout-logs/route.ts`
- Create: `lib/actions/save-workout-log.ts`
- Modify: dashboard components

**Step 1: Add server-side write path**
Save completion toggles and notes into `workout_logs`.

**Step 2: Load state from DB**
Render day completion from server data.

**Step 3: Verify**
Reload page and confirm data persists.

**Step 4: Commit**
```bash
git add app/api lib/actions components
git commit -m "feat: persist workout log updates"
```

### Task 7: Persist weekly check-ins and trigger reporting

**Objective:** Save athlete check-ins and automatically notify Dave.

**Files:**
- Create: `app/api/checkins/route.ts`
- Create: `lib/reporting/send-hermes-event.ts`
- Create: `lib/reporting/format-coach-update.ts`

**Step 1: Save weekly check-in to DB**
Insert into `weekly_checkins` and `timeline_events`.

**Step 2: POST event to Hermes**
Send signed webhook request after successful save.

**Step 3: Log delivery result**
Write success/failure to `delivery_events`.

**Step 4: Commit**
```bash
git add app/api/checkins lib/reporting
git commit -m "feat: report athlete checkins to coach"
```

### Task 8: Enable Hermes webhook receiver

**Objective:** Make Hermes accept secure app events and relay them to Dave.

**Files:**
- Create or modify Hermes config outside repo
- Create: `docs/integrations/hermes-webhook-setup.md`

**Step 1: Enable webhook platform in Hermes**
Document config and secret setup.

**Step 2: Define inbound event contract**
Describe payload schema and signature validation.

**Step 3: Verify**
Send a test event and confirm Telegram delivery to Dave target.

**Step 4: Commit docs**
```bash
git add docs/integrations/hermes-webhook-setup.md
git commit -m "docs: add hermes webhook integration setup"
```

### Task 9: Build coach dashboard

**Objective:** Give Dave a private control panel for all assigned athletes.

**Files:**
- Create: `app/(coach)/coach/page.tsx`
- Create: `app/(coach)/coach/athletes/[athleteId]/page.tsx`
- Create: `components/coach/athlete-list.tsx`
- Create: `components/coach/plan-editor.tsx`

**Step 1: Add athlete summary list**
Show latest check-in, recovery trend, and adherence.

**Step 2: Add athlete detail page**
Include plan editor, check-in history, and timeline.

**Step 3: Add push-plan-update action**
When Dave updates a plan, athlete dashboard reflects latest version and timeline event is created.

**Step 4: Commit**
```bash
git add app/(coach) components/coach
git commit -m "feat: add coach management dashboard"
```

### Task 10: Add progress photo uploads

**Objective:** Support before/after visual tracking securely.

**Files:**
- Create: `app/api/progress-photos/route.ts`
- Modify: `components/dashboard/journey-timeline.tsx`
- Create: `supabase/storage/README.md`

**Step 1: Create private storage bucket policy**
Bucket must be private.

**Step 2: Add upload flow**
Athlete uploads front/side/back photos.

**Step 3: Add signed URL rendering**
Only athlete, assigned coach, and admin can view them.

**Step 4: Commit**
```bash
git add app/api/progress-photos components/dashboard supabase/storage/README.md
git commit -m "feat: add secure progress photo timeline"
```

### Task 11: Add event digesting and coach summaries

**Objective:** Prevent Dave from being spammed by every micro-update.

**Files:**
- Create: `docs/integrations/digest-rules.md`
- Create: Hermes cron job prompt/config later

**Step 1: Define immediate vs batched events**
- immediate: weekly check-in submitted, milestone photo uploaded, plan updated
- batched: repeated checkbox changes during one workout

**Step 2: Add digest logic**
Either app-side batching or Hermes cron summarization.

**Step 3: Commit docs/code**
```bash
git add docs/integrations/digest-rules.md
git commit -m "docs: define coach notification digest rules"
```

### Task 12: SaaS onboarding for multiple athletes

**Objective:** Support more than one user cleanly.

**Files:**
- Create: `app/(marketing)/page.tsx`
- Create: `app/(coach)/coach/invite/page.tsx`
- Create: `app/api/invitations/route.ts`

**Step 1: Add athlete invite flow**
Dave invites athlete by email.

**Step 2: Create assignment on signup**
When athlete signs up, attach them to Dave's coach profile.

**Step 3: Verify multi-tenant isolation**
Athlete A cannot see Athlete B.

**Step 4: Commit**
```bash
git add app/(marketing) app/(coach)/coach/invite app/api/invitations
git commit -m "feat: add multi-athlete onboarding flow"
```

---

## Verification checklist

Before calling v1 complete, verify all of the following with real tests:
- athlete login works
- coach login works
- unauthorized user cannot access athlete dashboard
- athlete can mark workout complete
- athlete can submit weekly check-in
- athlete can upload progress snapshots
- Dave receives a Telegram update from Hermes after athlete submission
- coach can update a plan and athlete sees the updated plan
- RLS blocks cross-user reads/writes
- mobile dashboard layout works at common widths (390px, 430px, 768px, 1024px)

---

## Deployment recommendation

### Recommended deployment split
- **App:** Vercel or Netlify for Next.js
- **Database/Auth/Storage:** Supabase
- **Messaging/reporting:** Hermes on VPS

### Why this split works
- frontend stays easy to ship
- Supabase handles secure app data
- Hermes stays where your Telegram/Dave automations already live

---

## Final recommendation

Yes — this should become a SaaS.

And yes — the right direction is:
1. **Supabase-authenticated multi-user app**
2. **Dave as coach/admin**
3. **Per-athlete private dashboard**
4. **Hermes reporting bridge to Telegram**
5. **Later AI-assisted plan drafting once manual coaching flow is stable**

Do **not** try to keep this as just a static Netlify page anymore if you want secure editing, private user dashboards, and automated coach reporting.
