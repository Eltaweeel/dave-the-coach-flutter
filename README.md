# Dave the COACH Flutter App

Installable Flutter web / PWA foundation for the separate Dave the COACH SaaS v1.

## Public app URL
- `https://eltaweeel.github.io/dave-the-coach-flutter/`

This is the public launch URL.
Athletes and coaches can open this link directly.
The URL is public, but private athlete data is protected through Supabase authentication and row-level security.

## Repo
- `https://github.com/Eltaweeel/dave-the-coach-flutter`

## What is implemented now
- Flutter web / PWA app shell
- public launch screen
- real auth flow wiring for Supabase
- athlete + coach signup/login routes
- athlete profile loading
- weekly check-in save flow
- coach roster loading
- optional Dave webhook reporting after check-in save
- Supabase SQL migration + setup docs

## What is still required for true production use
You still need to connect a real Supabase project and set GitHub Pages build variables.
Without those runtime values, the app remains publicly reachable but login cannot activate real private data.

## GitHub Pages build configuration
Add these to the GitHub repo settings for `Eltaweeel/dave-the-coach-flutter`:

### Required
- Repository variable: `SUPABASE_URL`
- Repository secret or variable: `SUPABASE_ANON_KEY`

### Optional
- Repository variable: `DAVE_WEBHOOK_URL`
- Repository secret: `DAVE_WEBHOOK_SECRET`

## Local commands
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

## Backend setup
See:
- `docs/setup/supabase.md`
- `supabase/migrations/0001_profiles_and_checkins.sql`

## Privacy model
Public:
- app URL
- frontend bundle
- login/signup screens

Private:
- athlete profiles
- check-ins
- coach roster visibility

Privacy is enforced by Supabase Auth + RLS.

## Next recommended step
1. create the real Supabase project
2. apply the migration
3. set GitHub Pages variables/secrets
4. assign initial athletes to Dave in `athlete_profiles.coach_id`
5. test real sign-up and login from the public URL
