create extension if not exists "uuid-ossp";

-- /////////////////////////////////////////////// COMPILERS ///////////////////////////////////////////////////////////

create table app_public.compilers (
	id uuid primary key default uuid_generate_v1mc(),
	name text not null check (char_length(name) < 30),
	alias text default null check (char_length(name) < 30),
	code text default null check (char_length(code) < 100),
	version text not null unique check (char_length(version) < 10),
	language_id uuid not null references app_public.programming_languages(id) on delete restrict,
	comment text not null check (char_length(comment) < 300),

	-- Use boolean for set another type of table not a best practice,
	-- but inheritance in current scenario will be create more problems
	-- Firstly, PostgreSQL not have abstract class,
	-- so would be inherit compilers from interpreters or interpreters from compilers?
    -- Secondly, using two tables for this types will require additional logic on client
	is_interpreter boolean default false,

	created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

	unique (name, version)
);

alter table app_public.compilers enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.compilers
  for each row
  execute procedure app_private.tg__update_timestamps();

comment on table app_public.compilers is
    E'Compilers for programming languages';

comment on column app_public.compilers.name is
    E'Compiler name';

comment on column app_public.compilers.alias is
    E'Alias of compiler. Mostly used as search word, like gcc';

comment on column app_public.compilers.code is
    E'Compiler full code name aka "g++.exe (i686-posix-dwarf-rev0, Built by MinGW-W64 project) 8.1.0"';

comment on column app_public.compilers.version is
    E'Compiler version';

comment on column app_public.compilers.language_id is
    E'Language which compile';

comment on column app_public.compilers.is_interpreter is
    E'Is this interpreter';

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.compilers for select using (true);
create policy insert_teacher on app_public.compilers for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.compilers for update using (app_public.current_user_is_teacher());
create policy delete_teacher on app_public.compilers for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select       on app_public.compilers to orange_visitor;
grant insert(name, code, version, language_id, comment) on app_public.compilers to orange_visitor;
grant update(name, code, version, language_id, comment) on app_public.compilers to orange_visitor;
grant delete       on app_public.compilers to orange_visitor;

------------------------------------------------------------------------------------------------------------------------