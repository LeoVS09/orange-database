#!/bin/bash
set -e

echo "Installing or reinstalling the roles and database..."
# Now we can reset the database
psql -X -v ON_ERROR_STOP=1 template1 <<SQL
-- RESET database
DROP DATABASE IF EXISTS orange;
DROP DATABASE IF EXISTS orange_test;
DROP DATABASE IF EXISTS graphile_org_demo;
DROP ROLE IF EXISTS orange_visitor;
DROP ROLE IF EXISTS orange_admin;
DROP ROLE IF EXISTS orange_authenticator;
DROP ROLE IF EXISTS orange;

-- Now to set up the database cleanly:

-- Ref: https://devcenter.heroku.com/articles/heroku-postgresql#connection-permissions

-- This is the root role for the database
CREATE ROLE orange WITH LOGIN PASSWORD '${SUPERUSER_PASSWORD}' SUPERUSER;

-- This is the no-access role that PostGraphile will run as by default
CREATE ROLE orange_authenticator WITH LOGIN PASSWORD '${AUTH_USER_PASSWORD}' NOINHERIT;

-- This is the role that PostGraphile will switch to (from orange_authenticator) during a transaction
CREATE ROLE orange_visitor;

-- This enables PostGraphile to switch from orange_authenticator to orange_visitor
GRANT orange_visitor TO orange_authenticator;

-- Here's our main database
CREATE DATABASE orange OWNER orange;
REVOKE ALL ON DATABASE orange FROM PUBLIC;
GRANT CONNECT ON DATABASE orange TO orange;
GRANT CONNECT ON DATABASE orange TO orange_authenticator;
GRANT ALL ON DATABASE orange TO orange;

-- Some extensions require superuser privileges, so we create them before migration time.
\\connect orange
CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- This is a copy of the setup above for our test database
CREATE DATABASE orange_test OWNER orange;
REVOKE ALL ON DATABASE orange_test FROM PUBLIC;
GRANT CONNECT ON DATABASE orange_test TO orange;
GRANT CONNECT ON DATABASE orange_test TO orange_authenticator;
GRANT ALL ON DATABASE orange_test TO orange;

\\connect orange_test
CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
SQL

echo "Roles and databases created, now sourcing the initial database schema"
psql -X1 -v ON_ERROR_STOP=1 "${ROOT_DATABASE_URL}" -f database/reset.sql

echo "Insert admin login: $ADMIN_LOGIN, email: $ADMIN_EMAIL, password: $ADMIN_PASSWORD, and create profile"
psql -X -v ON_ERROR_STOP=1 "${ROOT_DATABASE_URL}"  template1 << SQL
select app_private.really_create_user(
  '${ADMIN_LOGIN}',
  '${ADMIN_EMAIL}',
  true,
  '${ADMIN_LOGIN}',
  'https://avatars1.githubusercontent.com/u/11697794?s=460&v=4',
  '${ADMIN_PASSWORD}',
  true
);
SQL

echo "Set initial database data"
psql -X1 -v ON_ERROR_STOP=1 "${ROOT_DATABASE_URL}" -f database/initial_data.sql

./bin/dump-schema.sh

# This dump method not export real server api, only database generated PostGraphile api
# ./bin/dump-graphql.sh

# All done
echo "✅ Database setup success"
