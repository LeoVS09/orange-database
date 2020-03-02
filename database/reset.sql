-- First, we clean out the old stuff

drop schema if exists app_public cascade;
drop schema if exists app_hidden cascade;
drop schema if exists app_private cascade;
drop schema if exists app_jobs cascade;

--------------------------------------------------------------------------------

-- Definitions <500 are common to all sorts of applications,
-- they solve common concerns such as storing user data,
-- logging people in, triggering password reset emails,
-- mitigating brute force attacks and more.

-- Background worker tasks
\ir 100_jobs.sql

-- app_public, app_private and base permissions
\ir 200_schemas.sql

-- Useful utility functions
\ir 300_utils.sql

-- Users, authentication, emails, etc
\ir 400_users.sql

-- Localisation data, languages of applications
\ir 450_languages.sql

--------------------------------------------------------------------------------

-- Definitions >=500 are application specific, defining the tables
-- in your application, and dealing with concerns such as a welcome
-- email or customising the user tables to your whim

-- Countries, cities, travels
\ir 500_geo.sql

-- User profiles, teachers, contestant
\ir 550_profiles.sql

-- Data domain
\ir 551_programming_languages.sql
\ir 552_code_editors.sql
\ir 553_compilers_and_interpreters.sql

-- Contest tasks, tags, tests...
\ir 600_problems.sql
\ir 650_solutions.sql

-- Teams of contestants
\ir 700_teams.sql

-- Contests
\ir 800_contests.sql
