create extension if not exists "uuid-ossp";

-- ////////////////////////////////////////////// CODE EDITORS /////////////////////////////////////////////////////////
-- Code editors can be used for statistic,
-- but basically they define before start contest what kind of editors will be available for contestant

create table app_public.code_editors (
	id uuid primary key default uuid_generate_v1mc(),
	name text not null constraint name_less_50 check (char_length(name) < 50),
	alias text default null constraint alias_less_50 check (char_length(alias) < 30),
	version text not null unique constraint version_less_50 check (char_length(name) < 200),

	created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

	unique (name, version)
);

alter table app_public.code_editors enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.code_editors
  for each row
  execute procedure app_private.tg__update_timestamps();

comment on table app_public.code_editors is
    E'Code editor, each row define one version of some code editor';

comment on column app_public.code_editors.name is
    E'Name of code editor. Use official name, like Visual Studio';

comment on column app_public.code_editors.alias is
    E'Alias for code editor. Mostly used as search keyword, like VSC';

comment on column app_public.code_editors.version is
    E'Version of code editor. Version is used for define which margin version is will be used, like Visual Studio 2017';

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.code_editors for select using (true);
create policy insert_teacher on app_public.code_editors for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.code_editors for update using (app_public.current_user_is_teacher());
create policy delete_teacher on app_public.code_editors for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select       on app_public.code_editors to orange_visitor;
grant insert(name, alias, version) on app_public.code_editors to orange_visitor;
grant update(name, alias, version) on app_public.code_editors to orange_visitor;
grant delete       on app_public.code_editors to orange_visitor;

-- ////////////////////////////////////////////// PROFILES TO CODE EDITORS /////////////////////////////////////////////

create table app_public.profiles_to_code_editors (
	profile_id uuid not null references app_public.profiles(id),
	code_editor_id uuid not null references app_public.code_editors(id),

	created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

	primary key (profile_id, code_editor_id)
);

alter table app_public.profiles_to_code_editors enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.profiles_to_code_editors
  for each row
  execute procedure app_private.tg__update_timestamps();

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.profiles_to_code_editors for select using (true);
create policy insert_admin on app_public.profiles_to_code_editors for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.profiles_to_code_editors for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.profiles_to_code_editors for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------

grant select       on app_public.profiles_to_code_editors to orange_visitor;
grant insert(profile_id, code_editor_id) on app_public.profiles_to_code_editors to orange_visitor;
grant delete       on app_public.profiles_to_code_editors to orange_visitor;

------------------------------------------------------------------------------------------------------------------------

create function app_public.profile_code_editors(p app_public.profiles)
returns setof app_public.code_editors as $$

	select app_public.code_editors.*
	from app_public.code_editors
	inner join app_public.profiles_to_code_editors
	on (app_public.profiles_to_code_editors.code_editor_id = app_public.code_editors.id)
	where app_public.profiles_to_code_editors.profile_id = p.id;

$$ language sql stable;

------------------------------------------------------------------------------------------------------------------------