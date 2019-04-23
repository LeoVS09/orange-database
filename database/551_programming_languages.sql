create extension if not exists "uuid-ossp";

-- //////////////////////////////////////////// PROGRAMMING LANGUAGES //////////////////////////////////////////////////
-- Definition of programming languages. They can be used for user personalisation and statistics,
-- but basically define which compiler or interpreter use to run code

create table app_public.programming_languages(
	id uuid primary key default uuid_generate_v1mc(),
	name text not null check (char_length(name) < 30),
	alias text default null check (char_length(alias) < 30),
	version text not null unique check (char_length(version) < 30),

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

	unique (name, version)
);

alter table app_public.programming_languages enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.programming_languages
  for each row
  execute procedure app_private.tg__update_timestamps();

comment on table app_public.programming_languages is
    E'Programming language, each row define one version of some language';

comment on column app_public.programming_languages.name is
    E'Name of language. Use official name, like C++, Go, JavaScript, but not cpp, Golang, ES';

comment on column app_public.programming_languages.alias is
    E'Alias for language. Mostly used as search keyword, like Golang, or define explicitly version of language, like ECMAScript';

comment on column app_public.programming_languages.version is
    E'Version of language. Version is used for compiler or interpreter. Also can have definition of used extensions and presets';

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.programming_languages for select using (true);
create policy insert_teacher on app_public.programming_languages for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.programming_languages for update using (app_public.current_user_is_teacher());
create policy delete_teacher on app_public.programming_languages for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select       on app_public.programming_languages to orange_visitor;
grant insert(name, alias, version) on app_public.programming_languages to orange_visitor;
grant update(name, alias, version) on app_public.programming_languages to orange_visitor;
grant delete       on app_public.programming_languages to orange_visitor;

-- ///////////////////////////////////////// PROFILES TO PROGRAMMING LANGUAGES /////////////////////////////////////////

create table app_public.profiles_to_programming_languages(
	profile_id uuid not null references app_public.profiles(id),
	language_id uuid not null references app_public.programming_languages (id),

	created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

	primary key (profile_id, language_id)
);

alter table app_public.profiles_to_programming_languages enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.profiles_to_programming_languages
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.profiles_to_programming_languages for select using (true);
create policy insert_admin on app_public.profiles_to_programming_languages for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.profiles_to_programming_languages for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.profiles_to_programming_languages for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select       on app_public.profiles_to_programming_languages to orange_visitor;
grant insert(profile_id, language_id) on app_public.profiles_to_programming_languages to orange_visitor;
grant delete       on app_public.profiles_to_programming_languages to orange_visitor;

------------------------------------------------------------------------------------------------------------------------

create function app_public.profile_programming_languages(p app_public.profiles)
returns setof app_public.programming_languages as $$

	select app_public.programming_languages.*
	from app_public.programming_languages
	inner join app_public.profiles_to_programming_languages
	on (app_public.profiles_to_programming_languages.language_id = app_public.programming_languages.id)
	where app_public.profiles_to_programming_languages.profile_id = p.id;

$$ language sql stable;

------------------------------------------------------------------------------------------------------------------------