create table public.student_login (
  id bigserial not null,
  name character varying(50) not null,
  status boolean not null,
  reason character varying(50) null,
  last_updated timestamp with time zone null default now(),
  constraint student_login_pkey primary key (id)
) TABLESPACE pg_default;


