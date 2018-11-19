#!/usr/bin/env make

.PHONY: all build start clean production start-dev dump-schema dump-graphql

export NODE_ENV=development

clean:
	rm -rf dist

build: clean
	./node_modules/.bin/babel ./src -d ./dist --extensions ".ts" --source-maps

production: clean
	./node_modules/.bin/babel ./src -d ./dist --extensions ".ts"

start: production
	./bin/start.sh

start-dev: build
	./bin/start-dev.sh

dump-schema:
	./bin/dump-schema.sh

dump-graphql:
	./bin/dump-graphql.sh
