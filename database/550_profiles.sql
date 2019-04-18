create extension if not exists "uuid-ossp";

-- ///////////////////////////////////////////////// PROFILES //////////////////////////////////////////////////////////

create table app_public.profiles (
	id uuid primary key default uuid_generate_v1mc(),
    user_id uuid references app_public.users(id) on delete cascade,

	first_name text default '' check (char_length(first_name) < 80),
	family_name text default '' check (char_length(family_name) < 80),
	last_name text default '' check (char_length(last_name) < 80),

	phone text default '' check (char_length(phone) < 16),

	group_number text default '' check (char_length(group_number) < 10),
	course smallint default null check (course > 0),

	city_id uuid default null references app_public.cities(id),
	university_id uuid default null references app_public.universities(id),

	created date not null default now(),
	updated date default null,

	is_teacher boolean default false
);

alter table app_public.profiles enable row level security;

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
	family_name,
	last_name,
	phone,
	group_number,
	course,
	city_id,
	university_id
) on app_public.profiles to orange_visitor;
grant update(
	first_name,
	family_name,
	last_name,
	phone,
	group_number,
	course,
	city_id,
	university_id
) on app_public.profiles to orange_visitor;

grant delete on app_public.profiles to orange_visitor;

-- ////////////////////////////////////////////////// TRAVELS //////////////////////////////////////////////////////////

create table app_public.profiles_to_travels (
	profile_id uuid not null references app_public.profiles(id),
	travel_id uuid not null references app_public.travels(id),
	primary key (profile_id, travel_id)
);

alter table app_public.profiles_to_travels enable row level security;

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.profiles_to_travels for select using (true);
create policy insert_admin on app_public.profiles_to_travels for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.profiles_to_travels for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.profiles_to_travels for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select       on app_public.profiles_to_travels to orange_visitor;
grant insert(profile_id, travel_id) on app_public.profiles_to_travels to orange_visitor;
grant delete       on app_public.profiles_to_travels to orange_visitor;

------------------------------------------------------------------------------------------------------------------------

create function app_public.profile_travels(p app_public.profiles)
returns setof app_public.travels as $$

	select app_public.travels.*
	from app_public.travels
	inner join app_public.profiles_to_travels
	on (app_public.profiles_to_travels.travel_id = app_public.travels.id)
	where app_public.profiles_to_travels.profile_id = p.id;

$$ language sql stable;