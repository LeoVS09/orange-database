#!/bin/bash
set -e
export NODE_ENV=development

if [ -x .env ]; then
  . ./.env
  if [ "$SUPERUSER_PASSWORD" = "" ]; then
    echo ".env already exists, but it doesn't define SUPERUSER_PASSWORD - aborting!"
    exit 1;
  fi
  if [ "$AUTH_USER_PASSWORD" = "" ]; then
    echo ".env already exists, but it doesn't define AUTH_USER_PASSWORD - aborting!"
    exit 1;
  fi
  echo "Configuration already exists, using existing secrets."
else
  # This will generate passwords that are safe to use in envvars without needing to be escaped:
  SUPERUSER_PASSWORD="$(openssl rand -base64 30 | tr '+/' '-_')"
  AUTH_USER_PASSWORD="$(openssl rand -base64 30 | tr '+/' '-_')"
  
  # This is template values for enviroment
  PGUSER="postgres"
  PGHOST="db"
  APP_NAME="orange"
  APP_DATABASE="orange"
  APP_VISITOR_NAME="orange_authenticator"
  APP_TEST_DATABASE="orange_test"
  PORT="8765"
  ROOT_DOMAIN="localhost:$PORT"
  

  # This is our '.env' config file, we're writing it now so that if something goes wrong we won't lose the passwords.
  cat >> .env <<CONFIG
# This dotenv file in format readable for docker https://docs.docker.com/compose/env-file/
# IMPORTANT: docker dotenv not fully support dotenv format!

# This is a development environment (production wouldn't write envvars to a file)
NODE_ENV=development

# Password for the '$APP_NAME' user, which owns the database
SUPERUSER_PASSWORD=$SUPERUSER_PASSWORD

# Password for the '$APP_VISITOR_NAME' user, which has very limited
# privileges, but can switch into orange_visitor
AUTH_USER_PASSWORD=$AUTH_USER_PASSWORD

# This secret is used for signing cookies
SECRET=$(openssl rand -base64 48)

# This secret is used for signing JWT tokens (we don't use this by default)
JWT_SECRET=$(openssl rand -base64 48)

# Used by psql tool for default connect to database
PGHOST=$PGHOST
PGUSER=$PGUSER
PGPASSWORD=$SUPERUSER_PASSWORD
POSTGRES_PASSWORD=$SUPERUSER_PASSWORD

# These are the connection strings for the DB and the test DB.
ROOT_DATABASE_URL=postgresql://$APP_NAME:$SUPERUSER_PASSWORD@$PGHOST/$APP_DATABASE
AUTH_DATABASE_URL=postgresql://$APP_VISITOR_NAME:$AUTH_USER_PASSWORD@$PGHOST/$APP_DATABASE
TEST_ROOT_DATABASE_URL=postgresql://$APP_NAME:$SUPERUSER_PASSWORD@$PGHOST/$APP_TEST_DATABASE
TEST_AUTH_DATABASE_URL=postgresql://$APP_VISITOR_NAME:$AUTH_USER_PASSWORD@$PGHOST/$APP_TEST_DATABASE

# This port is the one you'll connect to
PORT=$PORT

# This is needed any time we use absolute URLs, e.g. for OAuth callback URLs
ROOT_DOMAIN=$ROOT_DOMAIN
ROOT_URL=http://$ROOT_DOMAIN

# Our session store uses redis
REDIS_URL=redis://localhost/3

# Admin identification data
ADMIN_LOGIN=admin
# USED only because database user must have email
ADMIN_EMAIL=admin@admin.com
ADMIN_PASSWORD=$SUPERUSER_PASSWORD

# Create a GitHub application, by visiting
# https://github.com/settings/applications/new and then enter the Client
# ID/Secret below
#
#   Name: $APP_NAME
#   Homepage URL: http://localhost:8765
#   Authorization callback URL: http://localhost:8349/auth/github/callback
#
# Client ID:
GITHUB_KEY=
# Client Secret:
GITHUB_SECRET=

# Export schemas pathes
GRAPHQL_SCHEMA_PATH=schemas/schema.graphql
JSON_SCHEMA_PATH=schemas/schema.graphql.json
SQL_SCHEMA_PATH=./schemas/schema.sql

# Postgraphile introspection cache, use for improve startup time
PG_CACHE_PATH=./postgraphile.cache

CONFIG
  echo "Passwords generated and configuration written to .env"

  # To source our .env file from the shell it has to be executable.
  chmod +x .env

  . ./.env

  cat >> .env.admin <<CONFIG
# Admin panel variables (Forest Admin)
# https://docs.forestadmin.com/documentation/getting-started/installation
DATABASE_SCHEMA=app_public
DATABASE_URL=postgresql://$APP_NAME:$SUPERUSER_PASSWORD@$PGHOST/$APP_DATABASE
DATABASE_SSL=false
APP_NAME=$APP_NAME
FOREST_EMAIL=
# you can get it from http://app.forestadmin.com/
FOREST_TOKEN=
APPLICATION_HOST=localhost
APPLICATION_PORT=3310
CONFIG

  echo "Forest admin configuration was written to .env.admin"
fi

# All done
echo "✅ Setup success"