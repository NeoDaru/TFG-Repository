create function public.change_excursion_status(
  p_excursion_id uuid,
  p_new_status text
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_current text;
begin
  if not public.is_excursion_coordinator(p_excursion_id) then
    raise exception 'Not allowed';
  end if;

  select status into v_current
  from public.excursions
  where id = p_excursion_id
  for update;

  if not coalesce(
    (v_current = 'PLANNED' and p_new_status in ('IN_PROGRESS', 'CANCELLED'))
    or (v_current = 'IN_PROGRESS' and p_new_status = 'FINISHED'),
    false
  ) then
    raise exception 'invalid_transition';
  end if;

  update public.excursions
  set status = p_new_status
  where id = p_excursion_id;

  if p_new_status in ('FINISHED', 'CANCELLED') then
    delete from public.excursion_access_codes
    where excursion_id = p_excursion_id;
  end if;
end;
$$;

revoke execute on function public.change_excursion_status(uuid, text)
  from public, anon;
grant execute on function public.change_excursion_status(uuid, text)
  to authenticated;