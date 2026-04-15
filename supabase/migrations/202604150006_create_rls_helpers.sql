create or replace function public.get_current_user_id()
returns uuid
language sql
stable
as $$
  select id
  from public.users
  where auth_user_id = auth.uid()
    and deleted_at is null
  limit 1;
$$;
