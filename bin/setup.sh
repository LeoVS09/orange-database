#!/bin/bash
set -e
export NODE_ENV=development

if [ -x .env-config ]; then
  . ./.env-config
  if [ "$SUPERUSER_PASSWORD" = "" ]; then
    echo ".env-config already exists, but it doesn't define SUPERUSER_PASSWORD - aborting!"
    exit 1;
  fi
  if [ "$AUTH_USER_PASSWORD" = "" ]; then
    echo ".env-config already exists, but it doesn't define AUTH_USER_PASSWORD - aborting!"
    exit 1;
  fi
  echo "Configuration already exists, using existing secrets."
else
  # This will generate passwords that are safe to use in envvars without needing to be escaped:
  SUPERUSER_PASSWORD="$(openssl rand -base64 30 | tr '+/' '-_')"
  AUTH_USER_PASSWORD="$(openssl rand -base64 30 | tr '+/' '-_')"

  # This is our '.env-config' config file, we're writing it now so that if something goes wrong we won't lose the passwords.
  cat >> .env-config <<CONFIG
# This is a development environment (production wouldn't write envvars to a file)
export NODE_ENV="development"

# Password for the 'orange' user, which owns the database
export SUPERUSER_PASSWORD="$SUPERUSER_PASSWORD"

# Password for the 'orange_authenticator' user, which has very limited
# privileges, but can switch into orange_visitor
export AUTH_USER_PASSWORD="$AUTH_USER_PASSWORD"

# This secret is used for signing cookies
export SECRET="$(openssl rand -base64 48)"

# This secret is used for signing JWT tokens (we don't use this by default)
export JWT_SECRET="$(openssl rand -base64 48)"


# Used by psql tool for default connect to database
export PGHOST="db"
export PGUSER="postgres"

# These are the connection strings for the DB and the test DB.
export ROOT_DATABASE_URL="postgresql://orange:\$SUPERUSER_PASSWORD@\$PGHOST/orange"
export AUTH_DATABASE_URL="postgresql://orange_authenticator:\$AUTH_USER_PASSWORD@\$PGHOST/orange"
export TEST_ROOT_DATABASE_URL="postgresql://orange:\$SUPERUSER_PASSWORD@\$PGHOST/orange_test"
export TEST_AUTH_DATABASE_URL="postgresql://orange_authenticator:\$AUTH_USER_PASSWORD@\$PGHOST/orange_test"

# This port is the one you'll connect to
export PORT=8765

# This is needed any time we use absolute URLs, e.g. for OAuth callback URLs
export ROOT_DOMAIN="localhost:\$PORT"
export ROOT_URL="http://\$ROOT_DOMAIN"

# Our session store uses redis
export REDIS_URL="redis://localhost/3"

# Admin identification data
export ADMIN_LOGIN="admin"
# USED only because database user must have email
export ADMIN_EMAIL="admin@admin.com"
export ADMIN_PASSWORD="$SUPERUSER_PASSWORD"

# Create a GitHub application, by visiting
# https://github.com/settings/applications/new and then enter the Client
# ID/Secret below
#
#   Name: orange
#   Homepage URL: http://localhost:8765
#   Authorization callback URL: http://localhost:8349/auth/github/callback
#
# Client ID:
export GITHUB_KEY=""
# Client Secret:
export GITHUB_SECRET=""

# Export schemas pathes
export GRAPHQL_SCHEMA_PATH="schemas/schema.graphql"
export JSON_SCHEMA_PATH="schemas/schema.graphql.json"
export SQL_SCHEMA_PATH="./schemas/schema.sql"

# Postgraphile introspection cache, use for improve startup time
export PG_CACHE_PATH="./postgraphile.cache
"
CONFIG
  echo "Passwords generated and configuration written to .env-config"

  # To source our .env file from the shell it has to be executable.
  chmod +x .env-config

  . ./.env-config
fi


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
echo "✅ Setup success"
