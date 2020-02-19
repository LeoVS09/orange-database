#!/usr/bin/env bash

if [ -x ./.env-config ]; then
  . ./.env-config;
fi;

export NODE_ENV=production

echo "start production"

node ./dist/index.js
