create extension if not exists "uuid-ossp";

-- //////////////////////////////////////////// PROGRAM_INPUT_TYPE /////////////////////////////////////////////////////

create table app_public.program_input_type(
    id uuid primary key default uuid_generate_v1mc(),
    name text not null check (char_length(name) < 10),

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
grant insert(name) on app_public.program_input_type to orange_visitor;
grant update(name) on app_public.program_input_type to orange_visitor;
grant delete on app_public.program_input_type to orange_visitor;


-- //////////////////////////////////////////// PROGRAM_OUTPUT_TYPE ////////////////////////////////////////////////////

create table app_public.program_output_type(
    id uuid primary key default uuid_generate_v1mc(),
    name text not null check (char_length(name) < 10),

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
grant insert(name) on app_public.program_output_type to orange_visitor;
grant update(name) on app_public.program_output_type to orange_visitor;
grant delete on app_public.program_output_type to orange_visitor;


-- ///////////////////////////////////////////////// PROBLEMS //////////////////////////////////////////////////////////

create table app_public.problems (
	id uuid primary key default uuid_generate_v1mc(),
  name text not null check (char_length(name) < 80),
  description text not null,
  input_description text not null,
  output_description text not null,

  note text default null check (char_length(note) < 200),

  input_type uuid references app_public.program_input_type(id),
  output_type uuid references app_public.program_output_type(id),

  limit_time int not null,
  limit_memory int not null,

  is_open boolean default false,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  published_at timestamptz default null,

  author uuid references app_public.profiles(id) on delete restrict,
  tester uuid references app_public.profiles(id) on delete restrict default null
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

comment on column app_public.problems.input_type is
    E'Type input of problem, aka stdin';

comment on column app_public.problems.output_type is
    E'Type output of problem, aka stdout';

comment on column app_public.problems.limit_time is
    E'Time limit for problem. Units is milliseconds';

comment on column app_public.problems.limit_memory is
    E'Memory limit for problem. Units is bytes';

comment on column app_public.problems.is_open is
    E'Define if this problem can be visible in current moment';

comment on column app_public.problems.created_at is
    E'Date of problem creation';

comment on column app_public.problems.updated_at is
    E'Date of last problem modification';

comment on column app_public.problems.published_at is
    E'Date when problem must be open';

comment on column app_public.problems.author is
    E'\nCreator of problem';

comment on column app_public.problems.tester is
    E'Tester of problem';

comment on constraint problems_author_fkey on app_public.problems is
    E'@foreignFieldName problems_author\n@fieldName author_profile';

comment on constraint problems_tester_fkey on app_public.problems is
    E'@foreignFieldName problems_tester\n@fieldName tester_profile';

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.problems for select using (true);
create policy insert_teacher on app_public.problems for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.problems for update using (app_public.current_user_is_teacher());
create policy delete_teacher on app_public.problems for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.problems to orange_visitor;
grant insert(name, description, note, input_type, output_type, limit_time, limit_memory, is_open, published_at, author, tester) on app_public.problems to orange_visitor;
grant update(name, description, note, input_type, output_type, limit_time, limit_memory, is_open, published_at, author, tester) on app_public.problems to orange_visitor;
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

create table app_public.problems_to_tags(
	problem_id uuid not null references app_public.problems(id),
	tag_id uuid not null references app_public.tags(id),

	created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

	primary key (problem_id, tag_id)
);

alter table app_public.problems_to_tags enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.problems_to_tags
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.problems_to_tags for select using (true);
create policy insert_teacher on app_public.problems_to_tags for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.problems_to_tags for update using (app_public.current_user_is_teacher());
create policy delete_teacher on app_public.problems_to_tags for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select       on app_public.problems_to_tags to orange_visitor;
grant insert(problem_id, tag_id) on app_public.problems_to_tags to orange_visitor;
grant delete       on app_public.problems_to_tags to orange_visitor;

------------------------------------------------------------------------------------------------------------------------

create function app_public.problem_tags(p app_public.problems)
returns setof app_public.tags as $$

	select app_public.tags.*
	from app_public.tags
	inner join app_public.problems_to_tags
	on (app_public.problems_to_tags.tag_id = app_public.tags.id)
	where app_public.problems_to_tags.problem_id = p.id;

$$ language sql stable;

-- ///////////////////////////////////////////////// TESTS /////////////////////////////////////////////////////////////

create table app_public.tests (
    id uuid primary key default uuid_generate_v1mc(),
    index int not null,
    input text not null,
    output text not null,
    public boolean default true,

    problem_id uuid references app_public.problems on delete cascade,

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
grant insert(index, input, output, public) on app_public.tests to orange_visitor;
grant update(index, input, output, public) on app_public.tests to orange_visitor;
grant delete on app_public.tests to orange_visitor;

------------------------------------------------------------------------------------------------------------------------