#!/usr/bin/env bash

if [ -x ./.env ]; then
  . ./.env;
fi;

export NODE_ENV=development

echo "start development"

yarn nodemon:start
