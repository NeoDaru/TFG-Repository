create table public.excursions (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 100),
  description text not null default '' check (char_length(description) <= 500),
  start_at timestamptz not null,
  status text not null default 'PLANNED'
    check (status in ('PLANNED', 'IN_PROGRESS', 'FINISHED', 'CANCELLED')),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table public.excursion_members (
  excursion_id uuid not null references public.excursions(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null check (role in ('COORDINATOR', 'PARTICIPANT')),
  joined_at timestamptz not null default now(),
  primary key (excursion_id, user_id)
);

create index excursion_members_user_id_idx on public.excursion_members (user_id);

alter table public.excursions enable row level security;
alter table public.excursion_members enable row level security;

create function public.is_excursion_member(p_excursion_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.excursion_members
    where excursion_id = p_excursion_id
      and user_id = (select auth.uid())
  );
$$;

create policy "members view their excursions" on public.excursions
  for select to authenticated
  using (public.is_excursion_member(id));

create policy "members view members of their excursions" on public.excursion_members
  for select to authenticated
  using (public.is_excursion_member(excursion_id));

create function public.create_excursion(
  p_name text,
  p_description text,
  p_start_at timestamptz
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;
  if char_length(trim(coalesce(p_name, ''))) = 0 then
    raise exception 'Name is required';
  end if;

  insert into public.excursions (name, description, start_at, owner_id)
  values (trim(p_name), trim(coalesce(p_description, '')), p_start_at, auth.uid())
  returning id into v_id;

  insert into public.excursion_members (excursion_id, user_id, role)
  values (v_id, auth.uid(), 'COORDINATOR');

  return v_id;
end;
$$;

grant select on public.excursions, public.excursion_members to authenticated;
grant all on public.excursions, public.excursion_members to service_role;

revoke execute on function public.is_excursion_member(uuid) from public, anon;
grant execute on function public.is_excursion_member(uuid) to authenticated;

revoke execute on function public.create_excursion(text, text, timestamptz) from public, anon;
grant execute on function public.create_excursion(text, text, timestamptz) to authenticated;