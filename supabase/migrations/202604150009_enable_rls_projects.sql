alter table public.projects enable row level security;

create policy "projects_select_member_or_owner"
on public.projects
for select
using (
  owner_user_id = public.get_current_user_id()
  or exists (
    select 1
    from public.project_members pm
    where pm.project_id = projects.id
      and pm.user_id = public.get_current_user_id()
      and pm.is_active = true
      and pm.deleted_at is null
  )
);

create policy "projects_insert_authenticated"
on public.projects
for insert
with check (
  owner_user_id = public.get_current_user_id()
  and created_by_user_id = public.get_current_user_id()
  and updated_by_user_id = public.get_current_user_id()
);

create policy "projects_update_owner_or_admin"
on public.projects
for update
using (
  owner_user_id = public.get_current_user_id()
  or exists (
    select 1
    from public.project_members pm
    where pm.project_id = projects.id
      and pm.user_id = public.get_current_user_id()
      and pm.role in ('owner', 'admin')
      and pm.is_active = true
      and pm.deleted_at is null
  )
)
with check (
  owner_user_id = public.get_current_user_id()
  or exists (
    select 1
    from public.project_members pm
    where pm.project_id = projects.id
      and pm.user_id = public.get_current_user_id()
      and pm.role in ('owner', 'admin')
      and pm.is_active = true
      and pm.deleted_at is null
  )
);

create policy "projects_delete_owner_only"
on public.projects
for delete
using (
  owner_user_id = public.get_current_user_id()
);
