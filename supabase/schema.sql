begin;

create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  type text not null check (type in ('m3u', 'xtreamCodes')),
  m3u_url text, epg_url text, xc_username text, xc_password text, xc_url text,
  color_code bigint not null default 4284110808,
  created_at timestamptz not null default now()
);
create index if not exists profiles_user_id_idx on public.profiles(user_id);
alter table public.profiles enable row level security;
revoke all on public.profiles from anon;
grant select, insert, update, delete on public.profiles to authenticated;
grant all on public.profiles to service_role;
create policy "Users read own profiles" on public.profiles for select to authenticated
  using ((select auth.uid()) = user_id);
create policy "Users create own profiles" on public.profiles for insert to authenticated
  with check ((select auth.uid()) = user_id);
create policy "Users update own profiles" on public.profiles for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "Users delete own profiles" on public.profiles for delete to authenticated
  using ((select auth.uid()) = user_id);

create table if not exists public.app_settings (
  id integer primary key default 1 check (id = 1),
  latest_version text not null,
  release_notes text not null default '',
  apk_url text, windows_exe_url text,
  apk_sha256 text, windows_sha256 text,
  apk_urls jsonb not null default '{}'::jsonb,
  apk_sha256s jsonb not null default '{}'::jsonb
);
alter table public.app_settings enable row level security;
revoke all on public.app_settings from anon, authenticated;
grant select on public.app_settings to anon, authenticated;
grant all on public.app_settings to service_role;
create policy "Anyone reads update metadata" on public.app_settings for select
  to anon, authenticated using (true);
insert into public.app_settings(id, latest_version) values (1, '2.2.53')
  on conflict (id) do nothing;

notify pgrst, 'reload schema';
commit;
