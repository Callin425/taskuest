create table projects (
  id uuid primary key default gen_random_uuid(),

  name varchar(100) not null,
  description text,

  owner_user_id uuid not null,

  visibility varchar(20) not null default 'private',
  status varchar(20) not null default 'active',

  created_at timestamptz not null default now(),
  created_by_user_id uuid not null,

  updated_at timestamptz not null default now(),
  updated_by_user_id uuid not null,

  deleted_at timestamptz,
  deleted_by_user_id uuid,

  constraint fk_projects_owner
    foreign key (owner_user_id) references users(id),

  constraint fk_projects_created_by
    foreign key (created_by_user_id) references users(id),

  constraint fk_projects_updated_by
    foreign key (updated_by_user_id) references users(id),

  constraint fk_projects_deleted_by
    foreign key (deleted_by_user_id) references users(id),

  constraint chk_projects_visibility
    check (visibility in ('private', 'team')),

  constraint chk_projects_status
    check (status in ('active', 'archived'))
);
