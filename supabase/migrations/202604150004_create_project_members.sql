create table project_members (
  id uuid primary key default gen_random_uuid(),

  project_id uuid not null,
  user_id uuid not null,

  role varchar(20) not null default 'member',

  joined_at timestamptz not null default now(),
  invited_by_user_id uuid,

  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  created_by_user_id uuid not null,

  updated_at timestamptz not null default now(),
  updated_by_user_id uuid not null,

  deleted_at timestamptz,
  deleted_by_user_id uuid,

  constraint fk_pm_project
    foreign key (project_id) references projects(id) on delete cascade,

  constraint fk_pm_user
    foreign key (user_id) references users(id) on delete cascade,

  constraint fk_pm_invited_by
    foreign key (invited_by_user_id) references users(id),

  constraint fk_pm_created_by
    foreign key (created_by_user_id) references users(id),

  constraint fk_pm_updated_by
    foreign key (updated_by_user_id) references users(id),

  constraint fk_pm_deleted_by
    foreign key (deleted_by_user_id) references users(id),

  constraint uq_project_user
    unique (project_id, user_id),

  constraint chk_pm_role
    check (role in ('owner', 'admin', 'member'))
);
