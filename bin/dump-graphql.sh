#!/bin/bash

set -e

echo "Exporting GraphQL schema to ${GRAPHQL_SCHEMA_PATH} and ${JSON_SCHEMA_PATH}"
echo "Warning: This dump method not export real server api, only database generated PostGraphile api"

JSON_SCHEMA=$JSON_SCHEMA_PATH
echo "${JSON_SCHEMA}"

npx postgraphile -X \
   -c "${ROOT_DATABASE_URL}" \
   -s "app_public,app_private" \
   --export-schema-graphql "${GRAPHQL_SCHEMA_PATH}" \
   --export-schema-json "${JSON_SCHEMA_PATH}"

echo "✅ Dump graphql complete"
