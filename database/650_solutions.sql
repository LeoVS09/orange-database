create extension if not exists "uuid-ossp";

-- //////////////////////////////////////////////// SOLUTION ///////////////////////////////////////////////////////////

create table app_public.solutions(
    id uuid primary key default uuid_generate_v1mc(),
    code text not null,
    problem_id uuid not null references app_public.problems(id),
    translator_id uuid not null references app_public.translators(id),
    creator_id uuid not null references app_public.profiles (id),

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table app_public.solutions enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.solutions
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create function app_public.current_user_can_send_solution(problem_id uuid)
returns boolean as $$
    -- TODO: add contests support, and users rights
	select exists(
	    select 1 from app_public.problems where id = problem_id and publication_date <= now()
        );

$$ language sql stable;

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.solutions for select using (true);
create policy insert_contestant on app_public.solutions for insert with check (app_public.current_user_can_send_solution(problem_id));
create policy update_admin on app_public.solutions for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.solutions for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.solutions to orange_visitor;
grant insert(code, problem_id, translator_id, creator_id) on app_public.solutions to orange_visitor;
grant update(code, problem_id, translator_id, creator_id) on app_public.solutions to orange_visitor;
grant delete on app_public.solutions to orange_visitor;

-- //////////////////////////////////////////////// FAIL_TYPES /////////////////////////////////////////////////////////

create table app_public.fail_types (
    id uuid primary key default uuid_generate_v1mc(),
    name text not null,
    code int not null constraint file_type_code_must_be_unique unique,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table app_public.fail_types enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.fail_types
  for each row
  execute procedure app_private.tg__update_timestamps();

comment on table app_public.fail_types is
    E'Describe types of run program, aka "not equal test output", "exit with error",...';

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.fail_types for select using (true);
create policy insert_admin on app_public.fail_types for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.fail_types for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.fail_types for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.fail_types to orange_visitor;
grant insert(name, code) on app_public.fail_types to orange_visitor;
grant update(name, code) on app_public.fail_types to orange_visitor;
grant delete on app_public.fail_types to orange_visitor;

-- /////////////////////////////////////////////////// SOLUTION_RUN ////////////////////////////////////////////////////

create table app_public.solution_run (
    id uuid primary key default uuid_generate_v1mc(),
    solution_id uuid not null references app_public.solutions(id) on delete cascade,

    test_id uuid default null references app_public.tests(id) on delete set null,

    type_of_fail_id uuid default null references app_public.fail_types(id) on delete set null,
    output_of_failed_test  text default null,

    time_of_run timestamptz not null,
    used_memory int not null,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table app_public.solution_run enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.solution_run
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.solution_run for select using (true);
create policy insert_admin on app_public.solution_run for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.solution_run for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.solution_run for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.solution_run to orange_visitor;
grant insert(solution_id, test_id, type_of_fail_id, output_of_failed_test, time_of_run, used_memory) on app_public.solution_run to orange_visitor;
grant update(solution_id, test_id, type_of_fail_id, output_of_failed_test, time_of_run, used_memory) on app_public.solution_run to orange_visitor;
grant delete on app_public.solution_run to orange_visitor;

-- ////////////////////////////////////////////// SOLUTION_RUN_RESULT //////////////////////////////////////////////////

create table app_public.solution_result (
    id          uuid primary key default uuid_generate_v1mc(),
    problem_id uuid not null references app_public.problems (id) on delete cascade,
    solution_id uuid not null references app_public.solutions (id) on delete cascade,

    is_successful boolean not null,
    message text default null,

    failed_test_id uuid default null references app_public.tests(id) on delete set null,
    type_of_fail_id uuid default null references app_public.fail_types(id) on delete set null,
    fail_solution_run_id uuid default null references app_public.solution_run(id) on delete set null,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);


alter table app_public.solution_result enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.solution_result
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.solution_result for select using (true);
create policy insert_admin on app_public.solution_result for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.solution_result for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.solution_result for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.solution_result to orange_visitor;
grant insert(solution_id, problem_id, solution_id, is_successful, message, failed_test_id, type_of_fail_id, fail_solution_run_id) on app_public.solution_result to orange_visitor;
grant update(solution_id, problem_id, solution_id, is_successful, message, failed_test_id, type_of_fail_id, fail_solution_run_id) on app_public.solution_result to orange_visitor;
grant delete on app_public.solution_result to orange_visitor;