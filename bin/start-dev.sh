#!/usr/bin/env bash

if [ -x ./.env ]; then
  . ./.env;
fi;

export NODE_ENV=development

./node_modules/.bin/nodemon ./dist/index.js
