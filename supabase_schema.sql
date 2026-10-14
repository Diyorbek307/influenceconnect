-- ============================================================================
-- InfluenceConnect — схема базы данных для Supabase (бесплатный тариф).
-- Вставьте целиком в Supabase → SQL Editor → Run.
-- Включает таблицы, связи, индексы, Row Level Security и авто-создание профиля.
-- ============================================================================

-- ---------- PROFILES ----------
-- id совпадает с auth.users.id для реальных пользователей (заполняет триггер),
-- но FK намеренно не ставим, чтобы можно было засеять демо-блогеров
-- (витринные профили без аккаунта) через supabase_seed.sql.
create table if not exists public.profiles (
  id           uuid primary key default gen_random_uuid(),
  email        text,
  role         text not null default '',          -- 'brand' | 'blogger' | 'admin' | ''
  name         text not null default '',
  avatar_url   text not null default '',
  bio          text not null default '',
  category     text not null default '',
  location     text not null default '',
  platform     text not null default '',
  followers    integer not null default 0,
  engagement   double precision not null default 0,
  is_blocked   boolean not null default false,
  created_at   timestamptz not null default now()
);

-- ---------- CAMPAIGNS ----------
create table if not exists public.campaigns (
  id           uuid primary key default gen_random_uuid(),
  brand_id     uuid not null references public.profiles(id) on delete cascade,
  title        text not null,
  description  text not null default '',
  budget       integer not null default 0,
  category     text not null default '',
  image_url    text not null default '',
  status       text not null default 'active',     -- 'active' | 'closed' | 'pending'
  created_at   timestamptz not null default now()
);
create index if not exists campaigns_brand_idx on public.campaigns(brand_id);
create index if not exists campaigns_status_idx on public.campaigns(status);

-- ---------- SWIPES ----------
create table if not exists public.swipes (
  id           uuid primary key default gen_random_uuid(),
  from_id      uuid not null references public.profiles(id) on delete cascade,
  target_type  text not null,                      -- 'blogger' | 'campaign'
  target_id    uuid not null,
  liked        boolean not null default false,
  created_at   timestamptz not null default now(),
  unique (from_id, target_type, target_id)
);
create index if not exists swipes_target_idx on public.swipes(target_type, target_id);

-- ---------- Авто-создание профиля при регистрации ----------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- Авто-подтверждение email (чтобы вход работал сразу) ----------
-- Помечает новых пользователей как подтверждённых на уровне БД — не зависит
-- от настройки «Confirm email» в дашборде. Удобно для демо.
create or replace function public.auto_confirm_email()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if new.email_confirmed_at is null then
    new.email_confirmed_at := now();
  end if;
  return new;
end;
$$;

drop trigger if exists on_auth_user_autoconfirm on auth.users;
create trigger on_auth_user_autoconfirm
  before insert on auth.users
  for each row execute function public.auto_confirm_email();

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================
alter table public.profiles  enable row level security;
alter table public.campaigns enable row level security;
alter table public.swipes    enable row level security;

-- Проверка «я админ?»
create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists(
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'admin'
  );
$$;

-- PROFILES: все авторизованные видят профили; редактировать можно свой; админ — всё.
drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles
  for select to authenticated using (true);

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = auth.uid() or public.is_admin())
  with check (id = auth.uid() or public.is_admin());

drop policy if exists profiles_delete_admin on public.profiles;
create policy profiles_delete_admin on public.profiles
  for delete to authenticated using (public.is_admin());

-- CAMPAIGNS: читают все; создаёт/меняет владелец-бренд; админ — всё.
drop policy if exists campaigns_select on public.campaigns;
create policy campaigns_select on public.campaigns
  for select to authenticated using (true);

drop policy if exists campaigns_insert_own on public.campaigns;
create policy campaigns_insert_own on public.campaigns
  for insert to authenticated with check (brand_id = auth.uid());

drop policy if exists campaigns_update_own on public.campaigns;
create policy campaigns_update_own on public.campaigns
  for update to authenticated
  using (brand_id = auth.uid() or public.is_admin())
  with check (brand_id = auth.uid() or public.is_admin());

drop policy if exists campaigns_delete_own on public.campaigns;
create policy campaigns_delete_own on public.campaigns
  for delete to authenticated using (brand_id = auth.uid() or public.is_admin());

-- SWIPES: читают все авторизованные; пишет только автор свайпа.
drop policy if exists swipes_select on public.swipes;
create policy swipes_select on public.swipes
  for select to authenticated using (true);

drop policy if exists swipes_write_own on public.swipes;
create policy swipes_write_own on public.swipes
  for all to authenticated
  using (from_id = auth.uid())
  with check (from_id = auth.uid());

-- ============================================================================
-- Назначить себя администратором (выполнить ПОСЛЕ регистрации своего аккаунта):
--   update public.profiles set role = 'admin' where email = 'ВАШ_EMAIL';
-- ============================================================================
