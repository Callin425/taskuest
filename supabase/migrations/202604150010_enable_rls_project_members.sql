alter table public.project_members enable row level security;

create policy "project_members_select_same_project_members"
on public.project_members
for select
using (
  exists (
    select 1
    from public.project_members pm
    where pm.project_id = project_members.project_id
      and pm.user_id = public.get_current_user_id()
      and pm.is_active = true
      and pm.deleted_at is null
  )
);

create policy "project_members_insert_owner_or_admin"
on public.project_members
for insert
with check (
  exists (
    select 1
    from public.project_members pm
    where pm.project_id = project_members.project_id
      and pm.user_id = public.get_current_user_id()
      and pm.role in ('owner', 'admin')
      and pm.is_active = true
      and pm.deleted_at is null
  )
);

create policy "project_members_update_owner_or_admin"
on public.project_members
for update
using (
  exists (
    select 1
    from public.project_members pm
    where pm.project_id = project_members.project_id
      and pm.user_id = public.get_current_user_id()
      and pm.role in ('owner', 'admin')
      and pm.is_active = true
      and pm.deleted_at is null
  )
)
with check (
  exists (
    select 1
    from public.project_members pm
    where pm.project_id = project_members.project_id
      and pm.user_id = public.get_current_user_id()
      and pm.role in ('owner', 'admin')
      and pm.is_active = true
      and pm.deleted_at is null
  )
);

create policy "project_members_delete_owner_or_admin"
on public.project_members
for delete
using (
  exists (
    select 1
    from public.project_members pm
    where pm.project_id = project_members.project_id
      and pm.user_id = public.get_current_user_id()
      and pm.role in ('owner', 'admin')
      and pm.is_active = true
      and pm.deleted_at is null
  )
);
