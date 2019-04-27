create extension if not exists "uuid-ossp";

-- ///////////////////////////////////////////////// PROFILES //////////////////////////////////////////////////////////

create table app_public.profiles (
	id uuid primary key default uuid_generate_v1mc(),
    user_id uuid references app_public.users(id) on delete cascade,

	first_name text default '' check (char_length(first_name) < 80),
	middle_name text default '' check (char_length(middle_name) < 80),
	last_name text default '' check (char_length(last_name) < 80),

	phone text default '' check (char_length(phone) < 16),

	group_number text default '' check (char_length(group_number) < 10),
	course smallint default null check (course > 0),

	city_id uuid default null references app_public.cities(id),
	university_id uuid default null references app_public.universities(id),

    is_teacher boolean default false,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table app_public.profiles enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.profiles
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create function app_public.profiles_full_name(p app_public.profiles)
returns text as $$

    select trim(both from (p.first_name || ' ' || p.middle_name)) || ' ' || p.last_name;

$$ language sql stable;

------------------------------------------------------------------------------------------------------------------------

create function app_public.current_user_is_teacher() returns boolean as $$
  -- We're using exists here because it guarantees true/false rather than true/false/null
  select exists(
    select 1 from app_public.profiles where user_id = app_public.current_user_id() and is_teacher = true
	);
$$ language sql stable set search_path from current;
comment on function  app_public.current_user_is_teacher() is
  E'@omit\nHandy method to determine if the current user is an teacher.';

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.profiles for select using (true);
create policy insert_teacher on app_public.profiles for insert with check (app_public.current_user_is_teacher());
create policy update_self on app_public.profiles for update using (user_id = app_public.current_user_id());
create policy update_teacher on app_public.profiles for update using (app_public.current_user_is_teacher());
create policy delete_self on app_public.profiles for delete using (user_id = app_public.current_user_id());
create policy delete_admin on app_public.profiles for update using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.profiles to orange_visitor;
grant insert(
    first_name,
	middle_name,
	last_name,
	phone,
	group_number,
	course,
	city_id,
	university_id
) on app_public.profiles to orange_visitor;
grant update(
	first_name,
	middle_name,
	last_name,
	phone,
	group_number,
	course,
	city_id,
	university_id
) on app_public.profiles to orange_visitor;

grant delete on app_public.profiles to orange_visitor;

-- ////////////////////////////////////////////////// TRAVELS //////////////////////////////////////////////////////////

create table app_public.profiles_travels(
	profile_id uuid not null references app_public.profiles(id),
	travel_id uuid not null references app_public.travels(id),

	created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

	primary key (profile_id, travel_id)
);

alter table app_public.profiles_travels enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.profiles_travels
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.profiles_travels for select using (true);
create policy insert_admin on app_public.profiles_travels for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.profiles_travels for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.profiles_travels for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select       on app_public.profiles_travels to orange_visitor;
grant insert(profile_id, travel_id) on app_public.profiles_travels to orange_visitor;
grant delete       on app_public.profiles_travels to orange_visitor;

------------------------------------------------------------------------------------------------------------------------
