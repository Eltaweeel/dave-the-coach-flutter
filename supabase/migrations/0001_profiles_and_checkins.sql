create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  display_name text not null,
  role text not null check (role in ('athlete', 'coach')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.athlete_profiles (
  id uuid primary key references public.profiles(id) on delete cascade,
  coach_id uuid references public.profiles(id) on delete set null,
  goal text not null default 'Build elite calisthenics strength and consistency',
  training_level text not null default 'Intermediate',
  age integer,
  height_cm numeric,
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.weekly_checkins (
  id uuid primary key default gen_random_uuid(),
  athlete_id uuid not null references public.profiles(id) on delete cascade,
  week_start date not null,
  bodyweight_kg numeric not null,
  sleep_hours numeric not null,
  recovery_score integer not null check (recovery_score between 1 and 10),
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (athlete_id, week_start)
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.current_app_role()
returns text
language sql
stable
as $$
  select role from public.profiles where id = auth.uid()
$$;

create or replace function public.is_assigned_coach(target_athlete uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.athlete_profiles ap
    where ap.id = target_athlete
      and ap.coach_id = auth.uid()
  )
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists athlete_profiles_set_updated_at on public.athlete_profiles;
create trigger athlete_profiles_set_updated_at
before update on public.athlete_profiles
for each row execute function public.set_updated_at();

drop trigger if exists weekly_checkins_set_updated_at on public.weekly_checkins;
create trigger weekly_checkins_set_updated_at
before update on public.weekly_checkins
for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.athlete_profiles enable row level security;
alter table public.weekly_checkins enable row level security;

drop policy if exists profiles_self_read on public.profiles;
create policy profiles_self_read on public.profiles
for select using (
  id = auth.uid()
  or (
    role = 'athlete'
    and public.current_app_role() = 'coach'
    and public.is_assigned_coach(id)
  )
);

drop policy if exists profiles_self_insert on public.profiles;
create policy profiles_self_insert on public.profiles
for insert with check (id = auth.uid());

drop policy if exists profiles_self_update on public.profiles;
create policy profiles_self_update on public.profiles
for update using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists athlete_profiles_self_read on public.athlete_profiles;
create policy athlete_profiles_self_read on public.athlete_profiles
for select using (
  id = auth.uid()
  or public.is_assigned_coach(id)
);

drop policy if exists athlete_profiles_self_insert on public.athlete_profiles;
create policy athlete_profiles_self_insert on public.athlete_profiles
for insert with check (id = auth.uid());

drop policy if exists athlete_profiles_self_update on public.athlete_profiles;
create policy athlete_profiles_self_update on public.athlete_profiles
for update using (
  id = auth.uid() or public.is_assigned_coach(id)
)
with check (
  id = auth.uid() or public.is_assigned_coach(id)
);

drop policy if exists weekly_checkins_read on public.weekly_checkins;
create policy weekly_checkins_read on public.weekly_checkins
for select using (
  athlete_id = auth.uid() or public.is_assigned_coach(athlete_id)
);

drop policy if exists weekly_checkins_insert on public.weekly_checkins;
create policy weekly_checkins_insert on public.weekly_checkins
for insert with check (athlete_id = auth.uid());

drop policy if exists weekly_checkins_update on public.weekly_checkins;
create policy weekly_checkins_update on public.weekly_checkins
for update using (athlete_id = auth.uid()) with check (athlete_id = auth.uid());
