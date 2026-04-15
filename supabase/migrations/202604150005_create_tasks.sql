create table tasks (
  id uuid primary key default gen_random_uuid(),

  project_id uuid,
  owner_user_id uuid not null,

  title varchar(200) not null,
  description text,

  status varchar(20) not null default 'todo',
  priority varchar(20) not null default 'medium',

  assignee_user_id uuid,

  created_by_user_id uuid not null,
  updated_by_user_id uuid not null,

  due_date timestamptz,

  completion_rate integer not null default 0,
  xp_reward integer not null default 0,
  xp_granted_at timestamptz,

  completed_at timestamptz,

  archived_at timestamptz,
  archived_by_user_id uuid,

  sort_order integer not null default 0,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  deleted_at timestamptz,
  deleted_by_user_id uuid,

  constraint fk_tasks_project
    foreign key (project_id) references projects(id) on delete cascade,

  constraint fk_tasks_owner
    foreign key (owner_user_id) references users(id),

  constraint fk_tasks_assignee
    foreign key (assignee_user_id) references users(id),

  constraint fk_tasks_created_by
    foreign key (created_by_user_id) references users(id),

  constraint fk_tasks_updated_by
    foreign key (updated_by_user_id) references users(id),

  constraint fk_tasks_archived_by
    foreign key (archived_by_user_id) references users(id),

  constraint fk_tasks_deleted_by
    foreign key (deleted_by_user_id) references users(id),

  constraint chk_tasks_status
    check (status in ('todo', 'in_progress', 'done')),

  constraint chk_tasks_priority
    check (priority in ('low', 'medium', 'high', 'urgent')),

  constraint chk_tasks_completion
    check (completion_rate between 0 and 100),

  constraint chk_tasks_xp
    check (xp_reward >= 0)
);
