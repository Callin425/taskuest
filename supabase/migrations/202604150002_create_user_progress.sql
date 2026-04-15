create table user_progress (
  id uuid primary key default gen_random_uuid(),

  user_id uuid not null unique,
  level integer not null default 1,
  current_xp integer not null default 0,
  total_xp integer not null default 0,
  completed_task_count integer not null default 0,
  completed_project_count integer not null default 0,
  last_level_up_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint fk_user_progress_user
    foreign key (user_id) references users(id) on delete cascade,

  constraint chk_user_progress_level
    check (level >= 1),

  constraint chk_user_progress_xp
    check (current_xp >= 0 and total_xp >= 0),

  constraint chk_user_progress_counts
    check (completed_task_count >= 0 and completed_project_count >= 0)
);
