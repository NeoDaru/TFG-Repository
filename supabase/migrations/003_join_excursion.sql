create table public.excursion_access_codes (
  excursion_id uuid primary key references public.excursions(id) on delete cascade,
  code text not null unique check (code ~ '^[A-Z0-9]{12}$'),
  created_at timestamptz not null default now()
);

alter table public.excursion_access_codes enable row level security;

create function public.is_excursion_coordinator(p_excursion_id uuid)
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
      and role = 'COORDINATOR'
  );
$$;

create policy "coordinators view access code" on public.excursion_access_codes
  for select to authenticated
  using (public.is_excursion_coordinator(excursion_id));

create function public.generate_random_code()
returns text
language plpgsql
volatile
set search_path = ''
as $$
declare
  alphabet constant text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  random_bytes constant bytea := uuid_send(gen_random_uuid());
  positions constant int[] := array[0, 1, 2, 3, 4, 5, 7, 9, 10, 11, 12, 13];
  result text := '';
  pos int;
begin
  foreach pos in array positions loop
    result := result
      || substr(alphabet, (get_byte(random_bytes, pos) % length(alphabet)) + 1, 1);
  end loop;
  return result;
end;
$$;

create function public.generate_access_code(p_excursion_id uuid)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_code text;
begin
  if not public.is_excursion_coordinator(p_excursion_id) then
    raise exception 'Not allowed';
  end if;

  loop
    v_code := public.generate_random_code();
    begin
      insert into public.excursion_access_codes (excursion_id, code)
      values (p_excursion_id, v_code)
      on conflict (excursion_id)
        do update set code = excluded.code, created_at = now();
      return v_code;
    exception when unique_violation then
      null;
    end;
  end loop;
end;
$$;

create function public.join_excursion(p_code text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_code text := upper(regexp_replace(coalesce(p_code, ''), '[^A-Za-z0-9]', '', 'g'));
  v_excursion_id uuid;
  v_status text;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  select c.excursion_id, e.status
    into v_excursion_id, v_status
  from public.excursion_access_codes c
  join public.excursions e on e.id = c.excursion_id
  where c.code = v_code;

  if v_excursion_id is null then
    raise exception 'invalid_code';
  end if;

  if v_status not in ('PLANNED', 'IN_PROGRESS') then
    raise exception 'excursion_closed';
  end if;

  if exists (
    select 1 from public.excursion_members
    where excursion_id = v_excursion_id and user_id = auth.uid()
  ) then
    raise exception 'already_member';
  end if;

  insert into public.excursion_members (excursion_id, user_id, role)
  values (v_excursion_id, auth.uid(), 'PARTICIPANT');

  return v_excursion_id;
end;
$$;

grant select on public.excursion_access_codes to authenticated;
grant all on public.excursion_access_codes to service_role;

revoke execute on function public.generate_random_code()
  from public, anon, authenticated;

revoke execute on function public.is_excursion_coordinator(uuid) from public, anon;
grant execute on function public.is_excursion_coordinator(uuid) to authenticated;

revoke execute on function public.generate_access_code(uuid) from public, anon;
grant execute on function public.generate_access_code(uuid) to authenticated;

revoke execute on function public.join_excursion(text) from public, anon;
grant execute on function public.join_excursion(text) to authenticated;