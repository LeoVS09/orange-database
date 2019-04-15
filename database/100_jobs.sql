-- BEGIN: JOBS
--
-- An asynchronous job queue schema for ACID compliant job creation through
-- triggers/functions/etc.
--
-- Worker code: worker.js
--
-- Author: Benjie Gillam <code@benjiegillam.com>
-- License: MIT
-- URL: https://gist.github.com/benjie/839740697f5a1c46ee8da98a1efac218
-- Donations: https://www.paypal.me/benjie

create extension if not exists pgcrypto with schema public;
create extension if not exists "uuid-ossp" with schema public;

create schema if not exists app_jobs;

create table app_jobs.job_queues (
  queue_name varchar not null primary key,
  job_count int default 0 not null,
  locked_at timestamp with time zone,
  locked_by varchar
);
alter table app_jobs.job_queues enable row level security;

create table app_jobs.jobs (
  id uuid primary key default uuid_generate_v1mc(),
  queue_name varchar default (public.gen_random_uuid())::varchar not null,
  task_identifier varchar not null,
  payload json default '{}'::json not null,
  priority int default 0 not null,
  run_at timestamp with time zone default now() not null,
  attempts int default 0 not null,
  last_error varchar,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);
alter table app_jobs.job_queues enable row level security;

create function app_jobs.do_notify() returns trigger as $$
begin
  perform pg_notify(tg_argv[0], '');
  return new;
end;
$$ language plpgsql;

create function app_jobs.update_timestamps() returns trigger as $$
begin
  if tg_op = 'insert' then
    new.created_at = now();
    new.updated_at = now();
  elsif tg_op = 'update' then
    new.created_at = old.created_at;
    new.updated_at = greatest(now(), old.updated_at + interval '1 millisecond');
  end if;
  return new;
end;
$$ language plpgsql;

create function app_jobs.jobs__decrease_job_queue_count() returns trigger as $$
begin
  update app_jobs.job_queues
    set job_count = job_queues.job_count - 1
    where queue_name = old.queue_name
    and job_queues.job_count > 1;

  if not found then
    delete from app_jobs.job_queues where queue_name = old.queue_name;
  end if;

  return old;
end;
$$ language plpgsql;

create function app_jobs.jobs__increase_job_queue_count() returns trigger as $$
begin
  insert into app_jobs.job_queues(queue_name, job_count)
    values(new.queue_name, 1)
    on conflict (queue_name) do update set job_count = job_queues.job_count + 1;

  return new;
end;
$$ language plpgsql;

create trigger _100_timestamps before insert or update on app_jobs.jobs for each row execute procedure app_jobs.update_timestamps();
create trigger _500_increase_job_queue_count after insert on app_jobs.jobs for each row execute procedure app_jobs.jobs__increase_job_queue_count();
create trigger _500_decrease_job_queue_count before delete on app_jobs.jobs for each row execute procedure app_jobs.jobs__decrease_job_queue_count();
create trigger _900_notify_worker after insert on app_jobs.jobs for each statement execute procedure app_jobs.do_notify('jobs:insert');

create function app_jobs.add_job(identifier varchar, payload json) returns app_jobs.jobs as $$
  insert into app_jobs.jobs(task_identifier, payload) values(identifier, payload) returning *;
$$ language sql;

create function app_jobs.add_job(identifier varchar, queue_name varchar, payload json) returns app_jobs.jobs as $$
  insert into app_jobs.jobs(task_identifier, queue_name, payload) values(identifier, queue_name, payload) returning *;
$$ language sql;

create function app_jobs.schedule_job(identifier varchar, queue_name varchar, payload json, run_at timestamptz) returns app_jobs.jobs as $$
  insert into app_jobs.jobs(task_identifier, queue_name, payload, run_at) values(identifier, queue_name, payload, run_at) returning *;
$$ language sql;

create function app_jobs.complete_job(worker_id varchar, job_id uuid) returns app_jobs.jobs as $$
declare
  v_row app_jobs.jobs;
begin
  delete from app_jobs.jobs
    where id = job_id
    returning * into v_row;

  update app_jobs.job_queues
    set locked_by = null, locked_at = null
    where queue_name = v_row.queue_name and locked_by = worker_id;

  return v_row;
end;
$$ language plpgsql;

create function app_jobs.fail_job(worker_id varchar, job_id uuid, error_message varchar) returns app_jobs.jobs as $$
declare
  v_row app_jobs.jobs;
begin
  update app_jobs.jobs
    set
      last_error = error_message,
      run_at = greatest(now(), run_at) + (exp(least(attempts, 10))::text || ' seconds')::interval
    where id = job_id
    returning * into v_row;

  update app_jobs.job_queues
    set locked_by = null, locked_at = null
    where queue_name = v_row.queue_name and locked_by = worker_id;

  return v_row;
end;
$$ language plpgsql;

create function app_jobs.get_job(worker_id varchar, identifiers varchar[]) returns app_jobs.jobs as $$
declare
  v_job_id uuid;
  v_queue_name varchar;
  v_default_job_expiry text = (4 * 60 * 60)::text;
  v_default_job_maximum_attempts text = '25';
  v_row app_jobs.jobs;
begin
  if worker_id is null or length(worker_id) < 10 then
    raise exception 'invalid worker id';
  end if;

  select job_queues.queue_name, jobs.id into v_queue_name, v_job_id
    from app_jobs.job_queues
    inner join app_jobs.jobs using (queue_name)
    where (locked_at is null or locked_at < (now() - (coalesce(current_setting('jobs.expiry', true), v_default_job_expiry) || ' seconds')::interval))
    and run_at <= now()
    and attempts < coalesce(current_setting('jobs.maximum_attempts', true), v_default_job_maximum_attempts)::int
    and (identifiers is null or task_identifier = any(identifiers))
    order by priority asc, run_at asc, id asc
    limit 1
    for update skip locked;

  if v_queue_name is null then
    return null;
  end if;

  update app_jobs.job_queues
    set
      locked_by = worker_id,
      locked_at = now()
    where job_queues.queue_name = v_queue_name;

  update app_jobs.jobs
    set attempts = attempts + 1
    where id = v_job_id
    returning * into v_row;

  return v_row;
end;
$$ language plpgsql;

-- end: jobs
