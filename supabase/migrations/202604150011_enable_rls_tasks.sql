alter table public.tasks enable row level security;

create policy "tasks_select_own_or_project_member"
on public.tasks
for select
using (
  (
    project_id is null
    and owner_user_id = public.get_current_user_id()
  )
  or
  (
    project_id is not null
    and exists (
      select 1
      from public.project_members pm
      where pm.project_id = tasks.project_id
        and pm.user_id = public.get_current_user_id()
        and pm.is_active = true
        and pm.deleted_at is null
    )
  )
);

create policy "tasks_insert_own_or_project_member"
on public.tasks
for insert
with check (
  (
    project_id is null
    and owner_user_id = public.get_current_user_id()
    and created_by_user_id = public.get_current_user_id()
    and updated_by_user_id = public.get_current_user_id()
  )
  or
  (
    project_id is not null
    and exists (
      select 1
      from public.project_members pm
      where pm.project_id = tasks.project_id
        and pm.user_id = public.get_current_user_id()
        and pm.is_active = true
        and pm.deleted_at is null
    )
    and created_by_user_id = public.get_current_user_id()
    and updated_by_user_id = public.get_current_user_id()
  )
);

create policy "tasks_update_own_or_project_member"
on public.tasks
for update
using (
  (
    project_id is null
    and owner_user_id = public.get_current_user_id()
  )
  or
  (
    project_id is not null
    and exists (
      select 1
      from public.project_members pm
      where pm.project_id = tasks.project_id
        and pm.user_id = public.get_current_user_id()
        and pm.is_active = true
        and pm.deleted_at is null
    )
  )
)
with check (
  (
    project_id is null
    and owner_user_id = public.get_current_user_id()
  )
  or
  (
    project_id is not null
    and exists (
      select 1
      from public.project_members pm
      where pm.project_id = tasks.project_id
        and pm.user_id = public.get_current_user_id()
        and pm.is_active = true
        and pm.deleted_at is null
    )
  )
);

create policy "tasks_delete_own_or_project_member"
on public.tasks
for delete
using (
  (
    project_id is null
    and owner_user_id = public.get_current_user_id()
  )
  or
  (
    project_id is not null
    and exists (
      select 1
      from public.project_members pm
      where pm.project_id = tasks.project_id
        and pm.user_id = public.get_current_user_id()
        and pm.is_active = true
        and pm.deleted_at is null
    )
  )
);
