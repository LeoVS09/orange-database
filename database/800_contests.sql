create extension if not exists "uuid-ossp" with schema public;

-- //////////////////////////////////////////////////// CONTESTS ///////////////////////////////////////////////////////

create table app_public.contests (
    id uuid primary key default uuid_generate_v1mc(),
    name text not null check (char_length(name) < 160),
    text text default null,

    creator uuid not null references app_public.users(id),

    start_date date default null check ( start_date > now() ),
    end_date date default null constraint is_start_date_defined check ( start_date is not null ),

    visible_start_date date default null,
    visible_end_date date default null constraint is_visible_start_date_defined check ( visible_start_date is not null ),

    created date not null default now(),
    updated date default null,

    constraint end_must_be_after_start check ( start_date < end_date ),
    constraint visible_end_must_be_after_start check ( visible_start_date < visible_end_date )
);

alter table app_public.contests enable row level security;

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
    creator,
    start_date,
    end_date,
    visible_start_date,
    visible_end_date,
    created,
    updated
) on app_public.contests to orange_visitor;
grant update(
    name,
    text,
    creator,
    start_date,
    end_date,
    visible_start_date,
    visible_end_date,
    created,
    updated
) on app_public.contests to orange_visitor;
grant delete on app_public.contests to orange_visitor;

-- /////////////////////////////////////////////// CONTESTS TO TEAMS ///////////////////////////////////////////////////

create table app_public.contests_to_teams(
	contest_id uuid not null references app_public.contests(id),
	team_id uuid not null references app_public.teams(id),
	primary key (contest_id, team_id)
);

alter table app_public.contests_to_teams enable row level security;

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.contests_to_teams for select using (true);
create policy insert_teacher on app_public.contests_to_teams for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.contests_to_teams for update using (app_public.current_user_is_teacher());
create policy delete_teacher on app_public.contests_to_teams for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select       on app_public.contests_to_teams to orange_visitor;
grant insert(contest_id, team_id) on app_public.contests_to_teams to orange_visitor;
grant delete       on app_public.contests_to_teams to orange_visitor;

-- /////////////////////////////////////////////// CONTESTS TO PROFILES ////////////////////////////////////////////////

create table app_public.contests_to_profiles(
	contest_id uuid not null references app_public.contests(id),
	profile_id uuid not null references app_public.profiles(id),
	primary key (contest_id, profile_id)
);

alter table app_public.contests_to_profiles enable row level security;

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.contests_to_profiles for select using (true);
create policy insert_teacher on app_public.contests_to_profiles for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.contests_to_profiles for update using (app_public.current_user_is_teacher());
create policy delete_teacher on app_public.contests_to_profiles for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select       on app_public.contests_to_profiles to orange_visitor;
grant insert(contest_id, profile_id) on app_public.contests_to_profiles to orange_visitor;
grant delete       on app_public.contests_to_profiles to orange_visitor;

------------------------------------------------------------------------------------------------------------------------