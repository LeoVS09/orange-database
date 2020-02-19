#!/usr/bin/env bash

if [ -x ./.env-config ]; then
  . ./.env-config;
fi;

export NODE_ENV=development

echo "start development"

yarn nodemon:start
