create extension if not exists "uuid-ossp" with schema public;

------------------------------------------------------------------------------------------------------------------------

create table app_public.languages (
    id uuid primary key default uuid_generate_v1mc(),
    name text not null,
    code text not null
);

alter table app_public.languages enable row level security;

comment on table app_public.languages is
    E'Languages ​​from which the application is accessible';

comment on column app_public.languages.name is
    E'Language name is displayed to user';
comment on column app_public.languages.code is
    E'Language code is used in url or other places, aka "some.com/en/..."';

------------------------------------------------------------------------------------------------------------------------

create policy select_all   on app_public.languages for select using (true);
create policy insert_admin on app_public.languages for insert with check (app_public.current_user_is_admin());
create policy update_admin on app_public.languages for update using (app_public.current_user_is_admin());
create policy delete_admin on app_public.languages for delete using (app_public.current_user_is_admin());

------------------------------------------------------------------------------------------------------------------------