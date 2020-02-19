#!/usr/bin/env make

.PHONY: all build start clean production start-dev dump-schema dump-graphql setup dev docker-build docker-console build-console

export NODE_ENV=development
export COMPOSE_ENV_FILE='.env-list'

# ---------------------------------------------------------------------------------------------------------------------
# CONFIG
# ---------------------------------------------------------------------------------------------------------------------
DOCKER_IMAGE_VERSION=0.1.2
DOCKER_IMAGE_TAG=leovs09/orange-database:$(DOCKER_IMAGE_VERSION)

# ---------------------------------------------------------------------------------------------------------------------
# SETUP
# ---------------------------------------------------------------------------------------------------------------------

setup:
	./bin/setup.sh

# ---------------------------------------------------------------------------------------------------------------------
# UTILS
# ---------------------------------------------------------------------------------------------------------------------

clean:
	rm -rf build

env-to-list:
	node bin/env-to-list.js

# ---------------------------------------------------------------------------------------------------------------------
# DEVELOPMENT
# ---------------------------------------------------------------------------------------------------------------------

build: clean
	yarn build

start-dev:
	./bin/start-dev.sh

dev: build
	make watch & make start-dev

watch:
	yarn watch

# ---------------------------------------------------------------------------------------------------------------------
# PRODUCTION
# ---------------------------------------------------------------------------------------------------------------------

production: clean
	yarn production

start:
	./bin/start.sh

# ---------------------------------------------------------------------------------------------------------------------
# DUMP
# ---------------------------------------------------------------------------------------------------------------------

dump-schema:
	./bin/dump-schema.sh

dump-graphql:
	./bin/dump-graphql.sh

# ---------------------------------------------------------------------------------------------------------------------
# DOCKER
# ---------------------------------------------------------------------------------------------------------------------

docker-build-and-push:
	echo "Build and push $(DOCKER_IMAGE_TAG)"
	docker build -t orange-database .
	docker tag orange-database $(DOCKER_IMAGE_TAG)
	docker push $(DOCKER_IMAGE_TAG)

docker-build:
	@docker build -t $(DOCKER_IMAGE_TAG) .

docker-console: env-to-list
	docker-compose run --publish=8765:8765 orange-database  /bin/bash

console: docker-console

build-console: docker-build docker-console

db-up:
	docker-compose up db

docker-up:
	docker-compose up

