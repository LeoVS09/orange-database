create extension if not exists "uuid-ossp";

-- /////////////////////////////////////////////// TRANSLATORS /////////////////////////////////////////////////////////

create table app_public.translators (
	id uuid primary key default uuid_generate_v1mc(),
	name text not null check (char_length(name) < 30),
	alias text default null check (char_length(name) < 30),
	code text default null check (char_length(code) < 100),
	version text not null unique check (char_length(version) < 10),
	language_id uuid not null references app_public.programming_languages(id) on delete restrict,
	comment text not null check (char_length(comment) < 300),

	is_interpreter boolean default false,

	created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

	unique (name, version)
);

alter table app_public.translators enable row level security;

create trigger _100_timestamps
  after insert or update on app_public.translators
  for each row
  execute procedure app_private.tg__update_timestamps();

comment on table app_public.translators is
    E'Translators for programming languages';

comment on column app_public.translators.name is
    E'Translators name';

comment on column app_public.translators.alias is
    E'Alias of translator. Mostly used as search word, like gcc';

comment on column app_public.translators.code is
    E'Translators full code name aka "g++.exe (i686-posix-dwarf-rev0, Built by MinGW-W64 project) 8.1.0"';

comment on column app_public.translators.version is
    E'Translators version';

comment on column app_public.translators.language_id is
    E'Language which translate';

comment on column app_public.translators.is_interpreter is
    E'Is this interpreter ot compiler';

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.translators for select using (true);
create policy insert_teacher on app_public.translators for insert with check (app_public.current_user_is_teacher());
create policy update_teacher on app_public.translators for update using (app_public.current_user_is_teacher());
create policy delete_teacher on app_public.translators for delete using (app_public.current_user_is_teacher());

------------------------------------------------------------------------------------------------------------------------

grant select       on app_public.translators to orange_visitor;
grant insert(name, alias, code, version, language_id, comment, is_interpreter) on app_public.translators to orange_visitor;
grant update(name, alias, code, version, language_id, comment, is_interpreter) on app_public.translators to orange_visitor;
grant delete       on app_public.translators to orange_visitor;

------------------------------------------------------------------------------------------------------------------------

create view app_public.compilers as
    select *
    from app_public.translators
    where is_interpreter = false;

create view app_public.interpreters as
    select *
    from app_public.translators
    where is_interpreter = true;

------------------------------------------------------------------------------------------------------------------------

comment on view app_public.compilers is E'@primaryKey id';

comment on view app_public.compilers is E'@foreignKey (language_id) references app_public.programming_languages';

comment on view app_public.interpreters is E'@primaryKey id';

comment on view app_public.interpreters is E'@foreignKey (language_id) references app_public.programming_languages';

------------------------------------------------------------------------------------------------------------------------

alter table app_public.compilers owner to orange_visitor;

alter table app_public.interpreters owner to orange_visitor;
