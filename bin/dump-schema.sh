#!/bin/bash

set -e

. ./.env

echo "Dumping full SQL schema to data/schema.sql"

# There's no easy way to exclude postgraphile_watch from the dump, so we drop and and restore it at the end
echo "DROP SCHEMA IF EXISTS postgraphile_watch CASCADE;" | psql -X1 -v ON_ERROR_STOP=1 orange

# Here we do a schema only dump of the orange DB to the data folder
pg_dump -s -O -f ./schemas/schema.sql orange

# Restore the watch schema
cat ./node_modules/graphile-build-pg/res/watch-fixtures.sql | psql -X1 -v ON_ERROR_STOP=1 orange

echo "✅ Dump schema complete"
