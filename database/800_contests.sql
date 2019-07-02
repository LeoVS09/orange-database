create extension if not exists "uuid-ossp" with schema public;

-- //////////////////////////////////////////////////// CONTESTS ///////////////////////////////////////////////////////

create table app_public.contests (
    id uuid primary key default uuid_generate_v1mc(),
    name text not null check (char_length(name) < 160),
    text text default null,

    creator_id uuid not null references app_public.profiles(id),

    start_date timestamptz default null check ( start_date >= now() ),
    end_date timestamptz default null constraint is_start_date_defined check ( start_date is not null ),

    start_publication_date timestamptz default null,
    end_publication_date timestamptz default null constraint is_visible_start_date_defined check ( start_publication_date is not null ),

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()

    constraint end_must_be_after_start check ( start_date < end_date ),
    constraint visible_end_must_be_after_start check ( start_publication_date < end_publication_date )
);

alter table app_public.contests enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.contests
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.contests for select using (true);
create policy insert_teacher on app_public.contests for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.contests for update using (app_public.current_user_is_teacher());
create policy delete_admin on app_public.contests for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.contests to orange_visitor;
grant insert(
    name,
    text,
    creator_id,
    start_date,
    end_date,
    start_publication_date,
    end_publication_date
) on app_public.contests to orange_visitor;
grant update(
    name,
    text,
    creator_id,
    start_date,
    end_date,
    start_publication_date,
    end_publication_date
) on app_public.contests to orange_visitor;
grant delete on app_public.contests to orange_visitor;

-- /////////////////////////////////////////////// CONTESTS TO TEAMS ///////////////////////////////////////////////////

create table app_public.contests_teams
(
	contest_id uuid not null references app_public.contests(id),
	team_id uuid not null references app_public.teams(id),

	created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

	primary key (contest_id, team_id)
);

alter table app_public.contests_teams enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.contests_teams
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.contests_teams for select using (true);
create policy insert_teacher on app_public.contests_teams for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.contests_teams for update using (app_public.current_user_is_teacher());
create policy delete_teacher on app_public.contests_teams for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select       on app_public.contests_teams to orange_visitor;
grant insert(contest_id, team_id) on app_public.contests_teams to orange_visitor;
grant delete       on app_public.contests_teams to orange_visitor;

-- /////////////////////////////////////////////// CONTESTS TO PROFILES ////////////////////////////////////////////////

create table app_public.contests_profiles
(
	contest_id uuid not null references app_public.contests(id),
	profile_id uuid not null references app_public.profiles(id),

	created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

	primary key (contest_id, profile_id)
);

alter table app_public.contests_profiles enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.contests_profiles
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.contests_profiles for select using (true);
create policy insert_teacher on app_public.contests_profiles for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.contests_profiles for update using (app_public.current_user_is_teacher());
create policy delete_teacher on app_public.contests_profiles for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select       on app_public.contests_profiles to orange_visitor;
grant insert(contest_id, profile_id) on app_public.contests_profiles to orange_visitor;
grant delete       on app_public.contests_profiles to orange_visitor;

-- /////////////////////////////////////////////// CONTESTS TO PROBLEMS ////////////////////////////////////////////////

create table app_public.contests_problems
(
    contest_id uuid not null references app_public.contests(id),
    problem_id uuid not null references app_public.problems(id),

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

    primary key (contest_id, problem_id)
);

alter table app_public.contests_problems enable row level security;

create trigger _100_timestamps
    after insert or update on app_public.contests_problems
    for each row
    execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.contests_problems for select using (true);
create policy insert_teacher on app_public.contests_problems for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.contests_problems for update using (app_public.current_user_is_teacher());
create policy delete_teacher on app_public.contests_problems for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select       on app_public.contests_problems to orange_visitor;
grant insert(contest_id, problem_id) on app_public.contests_problems to orange_visitor;
grant delete       on app_public.contests_problems to orange_visitor;

------------------------------------------------------------------------------------------------------------------------

create view app_public.running_contests as
    select *
    from app_public.contests
    where start_date <= now() and now() <= end_date;

create view app_public.public_contests as
    select *
    from app_public.contests
    where start_publication_date <= now() and now() <= end_date;

create view app_public.public_running_contests as
    select *
    from app_public.running_contests
    where start_publication_date <= now() and now() <= end_date;

------------------------------------------------------------------------------------------------------------------------

comment on view app_public.running_contests is E'@primaryKey id';

comment on view app_public.running_contests is E'@foreignKey (creator_id) references app_public.profiles';

comment on view app_public.public_contests is E'@primaryKey id';

comment on view app_public.public_contests is E'@foreignKey (creator_id) references app_public.profiles';

comment on view app_public.public_running_contests is E'@primaryKey id';

comment on view app_public.public_running_contests is E'@foreignKey (creator_id) references app_public.profiles';

------------------------------------------------------------------------------------------------------------------------

alter table app_public.running_contests owner to orange_visitor;

alter table app_public.public_contests owner to orange_visitor;

alter table app_public.public_running_contests owner to orange_visitor;
