alter table public.users enable row level security;

create policy "users_select_own"
on public.users
for select
using (
  auth.uid() = auth_user_id
);

create policy "users_insert_own"
on public.users
for insert
with check (
  auth.uid() = auth_user_id
);

create policy "users_update_own"
on public.users
for update
using (
  auth.uid() = auth_user_id
)
with check (
  auth.uid() = auth_user_id
);

create policy "users_delete_own"
on public.users
for delete
using (
  auth.uid() = auth_user_id
);
