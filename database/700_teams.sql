create extension if not exists "uuid-ossp" with schema public;

-- //////////////////////////////////////////////////// TEAMS //////////////////////////////////////////////////////////
-- Teams of contestants, can be created by teachers or contestants when they combine

create table app_public.teams (
    id uuid primary key default uuid_generate_v1mc(),
    name text not null check (char_length(name) < 80),

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table app_public.teams enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.teams
  for each row
  execute procedure app_private.tg__update_timestamps();
------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.teams for select using (true);
create policy insert_teacher on app_public.teams for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.teams for update using (app_public.current_user_is_teacher());
create policy delete_teacher on app_public.teams for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.teams to orange_visitor;
grant insert(name) on app_public.teams to orange_visitor;
grant update(name) on app_public.teams to orange_visitor;
grant delete on app_public.teams to orange_visitor;

-- /////////////////////////////////////////////// TEAMS TO PROFILES ///////////////////////////////////////////////////

create table app_public.teams_to_profiles(
	team_id uuid not null references app_public.teams(id),
	profile_id uuid not null references app_public.profiles(id),

	created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

	primary key (team_id, profile_id)
);

alter table app_public.teams_to_profiles enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.teams_to_profiles
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.teams_to_profiles for select using (true);
create policy insert_teacher on app_public.teams_to_profiles for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.teams_to_profiles for update using (app_public.current_user_is_teacher());
create policy delete_teacher on app_public.teams_to_profiles for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select       on app_public.teams_to_profiles to orange_visitor;
grant insert(team_id, profile_id) on app_public.teams_to_profiles to orange_visitor;
grant delete       on app_public.teams_to_profiles to orange_visitor;

------------------------------------------------------------------------------------------------------------------------

create function app_public.team_profiles(t app_public.teams)
returns setof app_public.profiles as $$

	select app_public.profiles.*
	from app_public.profiles
	inner join app_public.teams_to_profiles
	on (app_public.teams_to_profiles.profile_id = app_public.profiles.id)
	where app_public.teams_to_profiles.team_id = t.id;

$$ language sql stable;

------------------------------------------------------------------------------------------------------------------------