create function public.update_excursion(
  p_excursion_id uuid,
  p_name text,
  p_description text,
  p_start_at timestamptz
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_status text;
begin
  if not public.is_excursion_coordinator(p_excursion_id) then
    raise exception 'Not allowed';
  end if;

  if char_length(trim(coalesce(p_name, ''))) = 0 then
    raise exception 'Name is required';
  end if;

  select status into v_status
  from public.excursions
  where id = p_excursion_id;

  if v_status not in ('PLANNED', 'IN_PROGRESS') then
    raise exception 'excursion_closed';
  end if;

  update public.excursions
  set name = trim(p_name),
      description = trim(coalesce(p_description, '')),
      start_at = p_start_at
  where id = p_excursion_id;
end;
$$;

revoke execute on function public.update_excursion(uuid, text, text, timestamptz)
  from public, anon;
grant execute on function public.update_excursion(uuid, text, text, timestamptz)
  to authenticated;