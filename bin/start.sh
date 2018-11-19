#!/usr/bin/env bash

if [ -x ../.env ]; then
  . ../.env;
fi;

export NODE_ENV=production

node ./dist/index.js
