create table users (
  id uuid primary key default gen_random_uuid(),

  auth_user_id uuid not null unique,
  display_name varchar(50) not null,
  email varchar(255) not null unique,
  avatar_url text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
