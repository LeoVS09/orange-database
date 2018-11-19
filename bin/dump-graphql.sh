#!/usr/bin/env bash

. ./.env

yarn postgraphile -X -c "${ROOT_DATABASE_URL}" -s "app_public,app_private" --export-schema-graphql schemas/schema.graphql --export-schema-json schemas/schema.graphql.json
