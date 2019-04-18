create extension if not exists "uuid-ossp";

-- /////////////////////////////////////// PROBLEMS ///////////////////////////////////////////////////

create table app_public.problems (
	id uuid primary key default uuid_generate_v1mc(),
  name text not null check (char_length(name) < 80),
  text text not null,
  note text default null check (char_length(note) < 200),

  limit_time int not null,
  limit_memory int not null,

  is_open boolean default false,

  created date not null,
  updated date default null,
  published date default null,

  author uuid references app_public.profiles(id) on delete restrict,
  tester uuid references app_public.profiles(id) on delete restrict default null
);

alter table app_public.problems enable row level security;

comment on table app_public.problems is
    E'nOlympiad programming task';

comment on column app_public.problems.name is
    E'Name of problem';

comment on column app_public.problems.text is
    E'Problem description';

comment on column app_public.problems.note is
    E'Addition note, mostly used be author and tester';

comment on column app_public.problems.limit_time is
    E'Time limit for problem. Units is milliseconds';

comment on column app_public.problems.limit_memory is
    E'Memory limit for problem. Units is bytes';

comment on column app_public.problems.is_open is
    E'Define if this problem can be visible in current moment';

comment on column app_public.problems.created is
    E'Date of problem creation';

comment on column app_public.problems.updated is
    E'Date of last problem modification';

comment on column app_public.problems.published is
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
grant insert(name, text, note, limit_time, limit_memory, is_open, updated, published, author, tester) on app_public.problems to orange_visitor;
grant update(name, text, note, limit_time, limit_memory, is_open, updated, published, author, tester) on app_public.problems to orange_visitor;
grant delete on app_public.problems to orange_visitor;

-- /////////////////////////////////////// TAGS ///////////////////////////////////////////////////

create table app_public.tags (
    id uuid primary key default uuid_generate_v1mc(),
    name text not null check(char_length(name) < 20)
);

alter table app_public.tags enable row level security;

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
	primary key (problem_id, tag_id)
);

alter table app_public.problems_to_tags enable row level security;

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

-- /////////////////////////////////////// PROGRAM_INPUT ///////////////////////////////////////////////////

create table app_public.program_input (
  id uuid primary key default uuid_generate_v1mc(),
  name text not null check (char_length(name) < 10)
);

alter table app_public.program_input enable row level security;

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.program_input for select using (true);
create policy insert_admin on app_public.program_input for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.program_input for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.program_input for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.program_input to orange_visitor;
grant insert(name) on app_public.program_input to orange_visitor;
grant update(name) on app_public.program_input to orange_visitor;
grant delete on app_public.program_input to orange_visitor;


-- /////////////////////////////////////// PROGRAM_OUTPUT ///////////////////////////////////////////////////

create table app_public.program_output (
  id uuid primary key default uuid_generate_v1mc()
) inherits (app_public.program_input);

alter table app_public.program_output enable row level security;

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.program_output for select using (true);
create policy insert_admin on app_public.program_output for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.program_output for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.program_output for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.program_output to orange_visitor;
grant insert(name) on app_public.program_output to orange_visitor;
grant update(name) on app_public.program_output to orange_visitor;
grant delete on app_public.program_output to orange_visitor;

-- /////////////////////////////////////// TESTS ///////////////////////////////////////////////////

create table app_public.tests (
    id uuid primary key default uuid_generate_v1mc(),
    index int not null,
    input text not null,
    output text not null,
    public boolean default true
);

alter table app_public.tests enable row level security;

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

create table app_public.problems_to_tests(
	problem_id uuid not null references app_public.problems(id),
	test_id uuid not null references app_public.tests(id),
	primary key (problem_id, test_id)
);

alter table app_public.problems_to_tests enable row level security;

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.problems_to_tests for select using (true);
create policy insert_teacher on app_public.problems_to_tests for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.problems_to_tests for update using (app_public.current_user_is_teacher());
create policy delete_teacher on app_public.problems_to_tests for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select       on app_public.problems_to_tests to orange_visitor;
grant insert(problem_id, test_id) on app_public.problems_to_tests to orange_visitor;
grant delete       on app_public.problems_to_tests to orange_visitor;

------------------------------------------------------------------------------------------------------------------------

create function app_public.problem_tests(p app_public.problems)
returns setof app_public.tests as $$

	select app_public.tests.*
	from app_public.tests
	inner join app_public.problems_to_tests
	on (app_public.problems_to_tests.test_id = app_public.tests.id)
	where app_public.problems_to_tests.problem_id = p.id;

$$ language sql stable;

-- /////////////////////////////////////// SOLUTION ///////////////////////////////////////////////////

create table app_public.solution (
    id uuid primary key default uuid_generate_v1mc(),
    code text not null,
    problem_id uuid not null references app_public.problems(id),
    compiler_id uuid not null references app_public.compilers(id),
    created date not null
);

alter table app_public.solution enable row level security;

------------------------------------------------------------------------------------------------------------------------

create function app_public.current_user_can_send_solution(problem_id uuid)
returns boolean as $$
    -- TODO: add contests support, and users rights
	select exists(
	    select 1 from app_public.problems where id = problem_id and is_open = true
        );

$$ language sql stable;

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.solution for select using (true);
create policy insert_contestant on app_public.solution for insert with check (app_public.current_user_can_send_solution(problem_id));
create policy update_admin on app_public.solution for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.solution for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.solution to orange_visitor;
grant insert(code, problem_id, compiler_id, created) on app_public.solution to orange_visitor;
grant update(code, problem_id, compiler_id, created) on app_public.solution to orange_visitor;
grant delete on app_public.solution to orange_visitor;

-- /////////////////////////////////////// FAIL_TYPES ///////////////////////////////////////////////////

create table app_public.fail_types (
    id uuid primary key default uuid_generate_v1mc(),
    name text not null
);

comment on table app_public.fail_types is
    E'Describe types of run program, aka "not equal test output", "exit with error",...';

alter table app_public.fail_types enable row level security;

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.fail_types for select using (true);
create policy insert_admin on app_public.fail_types for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.fail_types for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.fail_types for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.fail_types to orange_visitor;
grant insert(name) on app_public.fail_types to orange_visitor;
grant update(name) on app_public.fail_types to orange_visitor;
grant delete on app_public.fail_types to orange_visitor;

-- /////////////////////////////////////// SOLUTION_RUN ///////////////////////////////////////////////////

create table app_public.solution_run (
    id uuid primary key default uuid_generate_v1mc(),
    solution_id uuid not null references app_public.solution(id),
    failed_test_number int not null,
    is_all_tests_successful boolean default false,
    output_of_failed_test  text default null,
    time_of_failed_run date default null,
    type_of_fail uuid default null references app_public.fail_types(id),
    created date not null
);

alter table app_public.solution_run enable row level security;

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.solution_run for select using (true);
create policy insert_admin on app_public.solution_run for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.solution_run for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.solution_run for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.solution_run to orange_visitor;
grant insert(solution_id, failed_test_number, is_all_tests_successful, output_of_failed_test, time_of_failed_run, type_of_fail, created) on app_public.solution_run to orange_visitor;
grant update(solution_id, failed_test_number, is_all_tests_successful, output_of_failed_test, time_of_failed_run, type_of_fail, created) on app_public.solution_run to orange_visitor;
grant delete on app_public.solution_run to orange_visitor;

------------------------------------------------------------------------------------------------------------------------