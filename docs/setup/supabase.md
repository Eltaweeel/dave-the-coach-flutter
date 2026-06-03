# Supabase setup for Dave the COACH Flutter app

## 1. Create a Supabase project
Create a project for the Flutter app and keep these values:
- Project URL
- anon public key
- service role key (for admin tasks only, not for the public Flutter build)

## 2. Run the SQL migration
Apply:
- `supabase/migrations/0001_profiles_and_checkins.sql`

This creates:
- `profiles`
- `athlete_profiles`
- `weekly_checkins`
- row-level security policies for athlete privacy and coach visibility

## 3. Configure auth
Recommended settings:
- enable Email auth
- decide whether email confirmation is required
- if email confirmation is required, new users sign up first, then confirm email before first login

## 4. Configure role flow
The Flutter app writes `role` into:
- user metadata during sign-up
- `profiles.role` in the database

Supported roles:
- `athlete`
- `coach`

## 5. Assign athletes to coaches
Set `athlete_profiles.coach_id` to the coach's `profiles.id`.
That is what enables coach-side private visibility through RLS.

## 6. Configure GitHub Pages build variables
The public web app can stay publicly reachable, while private data remains protected by Supabase.

Set these in the GitHub repo used for Pages deployment:
- Repository variable: `SUPABASE_URL`
- Repository secret or variable: `SUPABASE_ANON_KEY`
- Optional variable: `DAVE_WEBHOOK_URL`
- Optional secret: `DAVE_WEBHOOK_SECRET`

## 7. Build locally with real config
```bash
export PATH=/opt/flutter/bin:$PATH
cd /root/dave-the-coach-flutter
flutter pub get
flutter test
flutter build web --release \
  --base-href /dave-the-coach-flutter/ \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY \
  --dart-define=DAVE_WEBHOOK_URL=https://your-webhook.example.com \
  --dart-define=DAVE_WEBHOOK_SECRET=YOUR_SECRET
```

## 8. What is public vs private
Public:
- app shell URL
- login/signup pages
- static frontend assets

Private:
- athlete profile rows
- weekly check-ins
- coach-only roster visibility

Privacy comes from Supabase auth + row-level security, not from hiding the frontend URL.
