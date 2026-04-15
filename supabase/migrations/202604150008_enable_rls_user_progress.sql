alter table public.user_progress enable row level security;

create policy "user_progress_select_own"
on public.user_progress
for select
using (
  user_id = public.get_current_user_id()
);

create policy "user_progress_insert_own"
on public.user_progress
for insert
with check (
  user_id = public.get_current_user_id()
);

create policy "user_progress_update_own"
on public.user_progress
for update
using (
  user_id = public.get_current_user_id()
)
with check (
  user_id = public.get_current_user_id()
);

create policy "user_progress_delete_own"
on public.user_progress
for delete
using (
  user_id = public.get_current_user_id()
);
