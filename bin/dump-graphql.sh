#!/usr/bin/env bash

. ./.env

echo "Exporting GraphQL schema to data/schema.graphql and data/schema.json"

npx postgraphile -X -c "${ROOT_DATABASE_URL}" -s "app_public,app_private" --export-schema-graphql schemas/schema.graphql --export-schema-json schemas/schema.graphql.json

echo "✅ Dump graphql complete"
