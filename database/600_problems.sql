create extension if not exists "uuid-ossp";

-- //////////////////////////////////////////// PROGRAM_INPUT_TYPE /////////////////////////////////////////////////////

create table app_public.program_input_type(
    id uuid primary key default uuid_generate_v1mc(),
    name text not null unique check (char_length(name) < 10),
    code text not null unique check (char_length(code) < 10),

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table app_public.program_input_type enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.program_input_type
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.program_input_type for select using (true);
create policy insert_admin on app_public.program_input_type for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.program_input_type for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.program_input_type for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.program_input_type to orange_visitor;
grant insert(name, code) on app_public.program_input_type to orange_visitor;
grant update(name, code) on app_public.program_input_type to orange_visitor;
grant delete on app_public.program_input_type to orange_visitor;


-- //////////////////////////////////////////// PROGRAM_OUTPUT_TYPE ////////////////////////////////////////////////////

create table app_public.program_output_type(
    id uuid primary key default uuid_generate_v1mc(),
    name text not null unique check (char_length(name) < 10),
    code text not null unique check (char_length(code) < 10),

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table app_public.program_output_type enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.program_output_type
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.program_output_type for select using (true);
create policy insert_admin on app_public.program_output_type for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.program_output_type for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.program_output_type for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.program_output_type to orange_visitor;
grant insert(name, code) on app_public.program_output_type to orange_visitor;
grant update(name, code) on app_public.program_output_type to orange_visitor;
grant delete on app_public.program_output_type to orange_visitor;


-- ///////////////////////////////////////////////// PROBLEMS //////////////////////////////////////////////////////////

create table app_public.problems (
	id uuid primary key default uuid_generate_v1mc(),
  name text not null check (char_length(name) < 80),
  description text not null,
  input_description text not null,
  output_description text not null,

  note text default null check (char_length(note) < 200),

  input_type_id uuid not null references app_public.program_input_type(id),
  output_type_id uuid not null references app_public.program_output_type(id),

  limit_time int not null,
  limit_memory int not null,
  difficulty  smallint default 0 constraint only_positive_difficulty check (difficulty >= 0),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  publication_date timestamptz default null,

  author_id uuid not null references app_public.profiles(id) on delete restrict,
  tester_id uuid references app_public.profiles(id) on delete restrict default null
);

alter table app_public.problems enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.problems
  for each row
  execute procedure app_private.tg__update_timestamps();

comment on table app_public.problems is
    E'nOlympiad programming task';

comment on column app_public.problems.name is
    E'Name of problem';

comment on column app_public.problems.description is
    E'Problem description';

comment on column app_public.problems.input_description is
    E'Description for input data';

comment on column app_public.problems.output_description is
    E'Description for output data';

comment on column app_public.problems.note is
    E'Addition note, mostly used be author and tester';

comment on column app_public.problems.input_type_id is
    E'Type input of problem, aka stdin';

comment on column app_public.problems.output_type_id is
    E'Type output of problem, aka stdout';

comment on column app_public.problems.limit_time is
    E'Time limit for problem. Units is milliseconds';

comment on column app_public.problems.limit_memory is
    E'Memory limit for problem. Units is bytes';

comment on column app_public.problems.difficulty is
    E'Level of difficulty. Where 0 is very easy and 100 is very hard';

comment on column app_public.problems.created_at is
    E'Date of problem creation';

comment on column app_public.problems.updated_at is
    E'Date of last problem modification';

comment on column app_public.problems.publication_date is
    E'Define when this problem can be visible';

comment on column app_public.problems.author_id is
    E'\nCreator of problem';

comment on column app_public.problems.tester_id is
    E'Tester of problem';

--comment on constraint problems_author_fkey on app_public.problems is
--    E'@foreignFieldName problems_author\n@fieldName authorProfile';

--comment on constraint problems_tester_fkey on app_public.problems is
--    E'@foreignFieldName problems_tester\n@fieldName testerProfile';

--comment on constraint problems_input_type_fkey on app_public.problems is
--    E'@fieldName inputType'

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.problems for select using (true);
create policy insert_teacher on app_public.problems for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.problems for update using (app_public.current_user_is_teacher());
create policy delete_teacher on app_public.problems for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.problems to orange_visitor;
grant insert(name, description, note, input_type_id, output_type_id, limit_time, limit_memory, publication_date, author_id, tester_id) on app_public.problems to orange_visitor;
grant update(name, description, note, input_type_id, output_type_id, limit_time, limit_memory, publication_date, author_id, tester_id) on app_public.problems to orange_visitor;
grant delete on app_public.problems to orange_visitor;

-- ///////////////////////////////////////////////////// TAGS //////////////////////////////////////////////////////////

create table app_public.tags (
    id uuid primary key default uuid_generate_v1mc(),
    name text not null check(char_length(name) < 20),

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table app_public.tags enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.tags
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.tags for select using (true);
create policy insert_teacher on app_public.tags for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.tags for update using (app_public.current_user_is_teacher());
create policy delete_teacher on app_public.tags for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.tags to orange_visitor;
grant insert(name) on app_public.tags to orange_visitor;
grant update(name) on app_public.tags to orange_visitor;
grant delete on app_public.tags to orange_visitor;

------------------------------------------------------------------------------------------------------------------------

create table app_public.problems_tags(
	problem_id uuid not null references app_public.problems(id),
	tag_id uuid not null references app_public.tags(id),

	created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

	primary key (problem_id, tag_id)
);

alter table app_public.problems_tags enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.problems_tags
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.problems_tags for select using (true);
create policy insert_teacher on app_public.problems_tags for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.problems_tags for update using (app_public.current_user_is_teacher());
create policy delete_teacher on app_public.problems_tags for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select       on app_public.problems_tags to orange_visitor;
grant insert(problem_id, tag_id) on app_public.problems_tags to orange_visitor;
grant delete       on app_public.problems_tags to orange_visitor;

-- ///////////////////////////////////////////////// TESTS /////////////////////////////////////////////////////////////

create table app_public.tests (
    id uuid primary key default uuid_generate_v1mc(),
    index int not null,
    input text not null,
    output text not null,
    is_public boolean default false,

    problem_id uuid not null references app_public.problems on delete cascade,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table app_public.tests enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.tests
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.tests for select using (true);
create policy insert_teacher on app_public.tests for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.tests for update using (app_public.current_user_is_teacher());
create policy delete_teacher on app_public.tests for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.tests to orange_visitor;
grant insert(index, input, output, is_public, problem_id) on app_public.tests to orange_visitor;
grant update(index, input, output, is_public) on app_public.tests to orange_visitor;
grant delete on app_public.tests to orange_visitor;

------------------------------------------------------------------------------------------------------------------------