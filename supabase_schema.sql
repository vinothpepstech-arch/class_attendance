-- This schema is generated based on the application code analysis.

-- Table for user profiles
-- This table stores user information, including their role.
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  role text NOT NULL,
  full_name text NOT NULL,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users (id) ON DELETE CASCADE
);

-- Table for student attendance
-- Each row represents a single attendance submission for a student.
-- Note: Storing student names as strings might lead to inconsistencies.
-- A better design would be to have a separate 'students' table and reference the student ID here.
create table public.student_login (
  id bigserial not null,
  name character varying(50) not null,
  status boolean not null,
  reason character varying(50) null,
  last_updated timestamp with time zone null default now(),
  constraint student_login_pkey primary key (id)
) TABLESPACE pg_default;

-- Table for text announcements
-- Stores announcements created by admins or teachers.
CREATE TABLE public.announcements (
  id bigserial NOT NULL,
  title text NOT NULL,
  content text NOT NULL,
  created_at timestamp with time zone NULL DEFAULT now(),
  CONSTRAINT announcements_pkey PRIMARY KEY (id)
);

-- Table for audio announcements
-- This table is used as a queue for playing audio announcements.
CREATE TABLE public.play_queue (
  id bigserial NOT NULL,
  audio_file text NOT NULL,
  created_at timestamp with time zone NULL DEFAULT now(),
  CONSTRAINT play_queue_pkey PRIMARY KEY (id)
);