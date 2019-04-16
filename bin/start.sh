#!/usr/bin/env bash

if [ -x ./.env ]; then
  . ./.env;
fi;

export NODE_ENV=production

echo "start production"

node ./dist/index.js
