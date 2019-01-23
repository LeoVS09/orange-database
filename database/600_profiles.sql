create extension if not exists "uuid-ossp";

-- /////////////////////////////////////// COUNTRIES ///////////////////////////////////////////////////

create table app_public.countries (
	id uuid primary key default uuid_generate_v1mc(),
  name text not null check (char_length(name) < 80)
);

alter table app_public.countries enable row level security;

-----------------------------------------------------------------------------------------------------------

create policy select_all on app_public.countries for select using (true);
create policy insert_admin on app_public.countries for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.countries for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.countries for delete using (app_public.current_user_is_admin());

-----------------------------------------------------------------------------------------------------------

grant select on app_public.countries to orange_visitor;
grant insert(name) on app_public.countries to orange_visitor;
grant update(name) on app_public.countries to orange_visitor;
grant delete on app_public.countries to orange_visitor;

-----------------------------------------------------------------------------------------------------------

create function app_public.search_countries(search text)
returns setof app_public.countries as $$

	select countriy.*
	from app_public.countries as countriy
	where position(search in countriy.name) > 0

$$ language sql stable;

-----------------------------------------------------------------------------------------------------------

insert into app_public.countries(name) values
	('Russia'),
	('Canada'),
	('Belarus');

-- //////////////////////////////////////// CITIES /////////////////////////////////////////////////////

create table app_public.cities (
	id uuid primary key default uuid_generate_v1mc(),
	name text not null check (char_length(name) < 80),
  country_id uuid references app_public.countries(id) on delete cascade
);

alter table app_public.cities enable row level security;

-----------------------------------------------------------------------------------------------------------

create policy select_all on app_public.cities for select using (true);
create policy insert_admin on app_public.cities for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.cities for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.cities for delete using (app_public.current_user_is_admin());

-----------------------------------------------------------------------------------------------------------

grant select on app_public.cities to orange_visitor;
grant insert(name, country_id) on app_public.cities to orange_visitor;
grant update(name, country_id) on app_public.cities to orange_visitor;
grant delete on app_public.cities to orange_visitor;

-- ///////////////////////////////////// UNIVERSITIES //////////////////////////////////////////////////

create table app_public.universities (
	id uuid primary key default uuid_generate_v1mc(),

	country_id uuid references app_public.countries(id),
	city_id uuid references app_public.cities(id),

	short_name text not null check (char_length(short_name) < 80),
	long_name text check (char_length(long_name) < 300)
);

alter table app_public.universities enable row level security;

-----------------------------------------------------------------------------------------------------------

create policy select_all on app_public.universities for select using (true);
create policy insert_admin on app_public.universities for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.universities for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.universities for delete using (app_public.current_user_is_admin());

-----------------------------------------------------------------------------------------------------------

grant select on app_public.universities to orange_visitor;
grant insert(country_id, city_id, short_name, long_name) on app_public.universities to orange_visitor;
grant update(country_id, city_id, short_name, long_name) on app_public.universities to orange_visitor;
grant delete on app_public.universities to orange_visitor;

-- /////////////////////////////////////// PROFILES ////////////////////////////////////////////////////

create table app_public.profiles (
	id uuid primary key default uuid_generate_v1mc(),
  user_id uuid references app_public.users(id) on delete cascade,

	first_name text check (char_length(first_name) < 80),
	family_name text check (char_length(family_name) < 80),
	last_name text check (char_length(last_name) < 80),

	phone text check (char_length(phone) < 16),

	group_number text check (char_length(group_number) < 10),
	course smallint check (course > 0),

	city_id uuid references app_public.cities(id),
	country_id uuid references app_public.countries(id),
	university_id uuid references app_public.universities(id)
);

alter table app_public.profiles enable row level security;

-----------------------------------------------------------------------------------------------------------

create policy select_all on app_public.profiles for select using (true);
create policy update_self on app_public.profiles for update using (user_id = app_public.current_user_id());
create policy delete_self on app_public.profiles for delete using (user_id = app_public.current_user_id());

-----------------------------------------------------------------------------------------------------------

grant select on app_public.profiles to orange_visitor;

grant update(
	first_name,
	family_name,
	last_name,
	phone,
	group_number,
	course,
	city_id,
	country_id,
	university_id
) on app_public.profiles to orange_visitor;

grant delete on app_public.profiles to orange_visitor;

-- /////////////////////////////////////// LANGUAGES ////////////////////////////////////////////////////

create table app_public.languages (
	id uuid primary key default uuid_generate_v1mc(),
	name text not null check (char_length(name) < 10)
);

alter table app_public.profiles enable row level security;

-----------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.languages for select using (true);
create policy insert_admin on app_public.languages for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.languages for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.languages for delete using (app_public.current_user_is_admin());

-----------------------------------------------------------------------------------------------------------

grant select       on app_public.languages to orange_visitor;
grant insert(name) on app_public.languages to orange_visitor;
grant update(name) on app_public.languages to orange_visitor;
grant delete       on app_public.languages to orange_visitor;

-----------------------------------------------------------------------------------------------------------

create table app_public.profiles_to_languages (
	profile_id uuid not null references app_public.profiles(id),
	language_id uuid not null references app_public.languages(id),
	primary key (profile_id, language_id)
);

alter table app_public.profiles_to_languages enable row level security;

-----------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.profiles_to_languages for select using (true);
create policy insert_admin on app_public.profiles_to_languages for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.profiles_to_languages for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.profiles_to_languages for delete using (app_public.current_user_is_admin());

-----------------------------------------------------------------------------------------------------------

grant select       on app_public.profiles_to_languages to orange_visitor;
grant insert(profile_id, language_id) on app_public.profiles_to_languages to orange_visitor;
grant delete       on app_public.profiles_to_languages to orange_visitor;

-----------------------------------------------------------------------------------------------------------

create function app_public.profiles_languages(p app_public.profiles)
returns setof app_public.languages as $$

	select languages.*
	from app_public.languages
	inner join app_public.profiles_to_languages
	on (app_public.profiles_to_languages.language_id = languages.id)
	where app_public.profiles_to_languages.profile_id = p.id;

$$ language sql stable;

-- /////////////////////////////////////// CODE EDITORS ////////////////////////////////////////////////////

create table app_public.code_editors (
	id uuid primary key default uuid_generate_v1mc(),
	name text not null check (char_length(name) < 10)
);

alter table app_public.code_editors enable row level security;

-----------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.code_editors for select using (true);
create policy insert_admin on app_public.code_editors for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.code_editors for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.code_editors for delete using (app_public.current_user_is_admin());

-----------------------------------------------------------------------------------------------------------

grant select       on app_public.code_editors to orange_visitor;
grant insert(name) on app_public.code_editors to orange_visitor;
grant update(name) on app_public.code_editors to orange_visitor;
grant delete       on app_public.code_editors to orange_visitor;

-----------------------------------------------------------------------------------------------------------

create table app_public.profiles_to_code_editors (
	profile_id uuid not null references app_public.profiles(id),
	code_editor_id uuid not null references app_public.code_editors(id),
	primary key (profile_id, code_editor_id)
);

alter table app_public.profiles_to_code_editors enable row level security;

-----------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.profiles_to_code_editors for select using (true);
create policy insert_admin on app_public.profiles_to_code_editors for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.profiles_to_code_editors for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.profiles_to_code_editors for delete using (app_public.current_user_is_admin());

-----------------------------------------------------------------------------------------------------------

grant select       on app_public.profiles_to_code_editors to orange_visitor;
grant insert(profile_id, code_editor_id) on app_public.profiles_to_code_editors to orange_visitor;
grant delete       on app_public.profiles_to_code_editors to orange_visitor;

-- ///////////////////////////////////////// TRAVELS ///////////////////////////////////////////////////////

create table app_public.travels (
	id uuid primary key default uuid_generate_v1mc(),
	arrival timestamptz not null,
	departure timestamptz not null,
	is_need_housing boolean not null default false
);

alter table app_public.travels enable row level security;

-----------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.travels for select using (true);
create policy insert_admin on app_public.travels for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.travels for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.travels for delete using (app_public.current_user_is_admin());

-----------------------------------------------------------------------------------------------------------

grant select       on app_public.travels to orange_visitor;
grant insert(arrival, departure, is_need_housing) on app_public.travels to orange_visitor;
grant update(arrival, departure, is_need_housing) on app_public.travels to orange_visitor;
grant delete       on app_public.travels to orange_visitor;

-----------------------------------------------------------------------------------------------------------

create table app_public.profiles_to_travels (
	profile_id uuid not null references app_public.profiles(id),
	travel_id uuid not null references app_public.travels(id),
	primary key (profile_id, travel_id)
);

alter table app_public.profiles_to_travels enable row level security;

-----------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.profiles_to_travels for select using (true);
create policy insert_admin on app_public.profiles_to_travels for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.profiles_to_travels for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.profiles_to_travels for delete using (app_public.current_user_is_admin());

-----------------------------------------------------------------------------------------------------------

grant select       on app_public.profiles_to_travels to orange_visitor;
grant insert(profile_id, travel_id) on app_public.profiles_to_travels to orange_visitor;
grant delete       on app_public.profiles_to_travels to orange_visitor;

