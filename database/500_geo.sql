create extension if not exists "uuid-ossp";

-- ///////////////////////////////////////////////// COUNTRIES /////////////////////////////////////////////////////////

create table app_public.countries (
	id uuid primary key default uuid_generate_v1mc(),
    name text not null check (char_length(name) < 80),
    code text not null check (char_length(code) < 3),

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table app_public.countries enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.countries
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.countries for select using (true);
create policy insert_admin on app_public.countries for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.countries for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.countries for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.countries to orange_visitor;
grant insert(name, code) on app_public.countries to orange_visitor;
grant update(name, code) on app_public.countries to orange_visitor;
grant delete on app_public.countries to orange_visitor;

------------------------------------------------------------------------------------------------------------------------

create function app_public.search_countries(search text)
returns setof app_public.countries as $$

	select countriy.*
	from app_public.countries as countriy
	where position(search in countriy.name) > 0

$$ language sql stable;

-- //////////////////////////////////////////////////// CITIES /////////////////////////////////////////////////////////

create table app_public.cities (
	id uuid primary key default uuid_generate_v1mc(),
	name text not null check (char_length(name) < 80),
    country_id uuid not null references app_public.countries(id) on delete cascade,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table app_public.cities enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.cities
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.cities for select using (true);
create policy insert_admin on app_public.cities for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.cities for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.cities for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.cities to orange_visitor;
grant insert(name, country_id) on app_public.cities to orange_visitor;
grant update(name, country_id) on app_public.cities to orange_visitor;
grant delete on app_public.cities to orange_visitor;

-- ///////////////////////////////////////////////// UNIVERSITIES //////////////////////////////////////////////////////

create table app_public.universities (
	id uuid primary key default uuid_generate_v1mc(),

	city_id uuid not null references app_public.cities(id),

	short_name text not null check (char_length(short_name) < 80),
	long_name text check (char_length(long_name) < 300),

	created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table app_public.universities enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.universities
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all on app_public.universities for select using (true);
create policy insert_admin on app_public.universities for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.universities for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.universities for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select on app_public.universities to orange_visitor;
grant insert(city_id, short_name, long_name) on app_public.universities to orange_visitor;
grant update(city_id, short_name, long_name) on app_public.universities to orange_visitor;
grant delete on app_public.universities to orange_visitor;

-- ////////////////////////////////////////////////// TRAVELS //////////////////////////////////////////////////////////

create table app_public.travels (
	id uuid primary key default uuid_generate_v1mc(),
	arrival_time timestamptz default null,
	arrival_place text default null, -- coordinates of arrival
	departure_time timestamptz default null,
	departure_place timestamptz default null, -- coordinates of departure
	is_need_housing boolean not null default false,
    commentary text default null,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table app_public.travels enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.travels
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.travels for select using (true);
create policy insert_admin on app_public.travels for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.travels for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.travels for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select       on app_public.travels to orange_visitor;
grant insert(arrival_time, arrival_place, departure_time, departure_place, is_need_housing, commentary) on app_public.travels to orange_visitor;
grant update(arrival_time, arrival_place, departure_time, departure_place, is_need_housing, commentary) on app_public.travels to orange_visitor;
grant delete       on app_public.travels to orange_visitor;