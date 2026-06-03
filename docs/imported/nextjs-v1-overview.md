# Dave the COACH SaaS overview

This repository now contains the first real app scaffold for the multi-user coaching SaaS.

## App sections
- `app/page.tsx` — public marketing entry
- `app/(auth)` — athlete and coach auth pages
- `app/(athlete)/dashboard` — athlete dashboard
- `app/(coach)/coach` — coach dashboard
- `app/(coach)/coach/athletes/[athleteId]` — coach athlete detail view

## Supabase-ready pieces
- `.env.example`
- `lib/env.ts`
- `lib/supabase/client.ts`
- `lib/supabase/server.ts`
- `supabase/migrations/0001_initial_schema.sql`
- `supabase/migrations/0002_rls_policies.sql`

## Current auth mode
- If Supabase env vars are provided, the auth forms are ready to use Supabase.
- If Supabase env vars are missing, the app falls back to server-cookie demo mode so the athlete and coach UI can still be previewed safely.

## Next wiring steps
1. Add real Supabase project keys to `.env.local`
2. Run the SQL migrations in Supabase
3. Replace demo data with server-loaded Supabase queries
4. Add athlete check-in save actions
5. Add Hermes webhook reporting to Dave
