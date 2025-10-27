-- ========================================
-- 0) 확장 (UUID 생성용)  ※ 이미 켜져있으면 그대로 통과
-- ========================================
create extension if not exists pgcrypto;

-- ========================================
-- 1) profiles — 사용자 프로필
-- ========================================
create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  display_name text,
  phone text,
  avatar_url text,
  email_notification boolean default true,
  push_notification boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.profiles enable row level security;

-- 기존 정책 제거(재실행 안전)
drop policy if exists "profiles_read_own"   on public.profiles;
drop policy if exists "profiles_insert_own" on public.profiles;
drop policy if exists "profiles_update_own" on public.profiles;

-- 정책 생성
create policy "profiles_read_own" on public.profiles
  for select using (auth.uid() = user_id);

create policy "profiles_insert_own" on public.profiles
  for insert with check (auth.uid() = user_id);

create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = user_id);

-- ========================================
-- 2) captures — 촬영 기록
-- ========================================
create table if not exists public.captures (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  image_url text,
  pill_count integer default 1,
  is_multi_mode boolean default false,
  capture_date timestamptz default now(),
  created_at timestamptz default now()
);

alter table public.captures enable row level security;

drop policy if exists "captures_read_own"   on public.captures;
drop policy if exists "captures_insert_own" on public.captures;
drop policy if exists "captures_delete_own" on public.captures;

create policy "captures_read_own" on public.captures
  for select using (auth.uid() = user_id);

create policy "captures_insert_own" on public.captures
  for insert with check (auth.uid() = user_id);

create policy "captures_delete_own" on public.captures
  for delete using (auth.uid() = user_id);

-- ========================================
-- 3) drug_results — 약품 검색/추론 결과
-- ========================================
create table if not exists public.drug_results (
  id uuid default gen_random_uuid() primary key,
  capture_id uuid references public.captures(id) on delete cascade not null,
  user_id uuid references auth.users(id) on delete cascade not null,
  drug_name text not null,
  drug_code text,
  accuracy numeric(5,2),
  ingredients jsonb,
  efficacy text,
  usage text,
  warnings text,
  manufacturer text,
  created_at timestamptz default now()
);

alter table public.drug_results enable row level security;

drop policy if exists "drug_results_read_own"   on public.drug_results;
drop policy if exists "drug_results_insert_own" on public.drug_results;

create policy "drug_results_read_own" on public.drug_results
  for select using (auth.uid() = user_id);

create policy "drug_results_insert_own" on public.drug_results
  for insert with check (auth.uid() = user_id);

-- ========================================
-- 4) user_settings — 사용자 설정
-- ========================================
create table if not exists public.user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  language text default 'ko',
  theme text default 'light',
  auto_save_captures boolean default true,
  updated_at timestamptz default now()
);

alter table public.user_settings enable row level security;

drop policy if exists "settings_read_own"  on public.user_settings;
drop policy if exists "settings_upsert_own" on public.user_settings;

create policy "settings_read_own" on public.user_settings
  for select using (auth.uid() = user_id);

-- upsert 허용(SELECT/INSERT/UPDATE/DELETE 모두에 같은 조건 적용)
create policy "settings_upsert_own" on public.user_settings
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ========================================
-- 5) 신규 유저 자동 프로비저닝 트리거
--    - profiles / user_settings 자동 생성
-- ========================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (user_id, email, display_name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1))
  )
  on conflict (user_id) do nothing;

  insert into public.user_settings (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- ========================================
-- 6) updated_at 자동 갱신 트리거
-- ========================================
create or replace function public.handle_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists update_profiles_updated_at on public.profiles;
create trigger update_profiles_updated_at
before update on public.profiles
for each row execute function public.handle_updated_at();

drop trigger if exists update_settings_updated_at on public.user_settings;
create trigger update_settings_updated_at
before update on public.user_settings
for each row execute function public.handle_updated_at();

-- ========================================
-- 7) 인덱스(성능)
-- ========================================
create index if not exists idx_captures_user_id      on public.captures(user_id);
create index if not exists idx_captures_created_at   on public.captures(created_at desc);
create index if not exists idx_drug_results_capture  on public.drug_results(capture_id);
create index if not exists idx_drug_results_user_id  on public.drug_results(user_id);