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

SETUP_COMMAND = ./bin/setup.sh

# This will detect OS and define setup command
ifeq ($(OS),Windows_NT)
	SETUP_COMMAND = make docker-base-linux-setup
endif

setup:
	$(SETUP_COMMAND)

# setup database with .sql scripts in ./database folder
setup-db:
	./bin/setup-db.sh

# ---------------------------------------------------------------------------------------------------------------------
# UTILS
# ---------------------------------------------------------------------------------------------------------------------

clean:
	yarn clean

# ---------------------------------------------------------------------------------------------------------------------
# DEVELOPMENT
# ---------------------------------------------------------------------------------------------------------------------

build: clean
	yarn build

start-dev:
	echo "Will start server in development mode"
	yarn start:dev

dev:
	echo "Will prepare for development and start server"
	yarn dev

watch:
	yarn watch

# ---------------------------------------------------------------------------------------------------------------------
# PRODUCTION
# ---------------------------------------------------------------------------------------------------------------------

# Build for production
production:
	echo "Will build for production"
	yarn production

start:
	echo "Will start server in production mode"
	yarn start

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

docker-base-linux-console:
	docker run -it -v ${CURDIR}:/data -w /data leovs09/debian-bash-make bash 

docker-base-linux-setup:
	docker run -it -v ${CURDIR}:/data -w /data leovs09/debian-bash-make make setup

docker-build-and-push:
	echo "Build and push $(DOCKER_IMAGE_TAG)"
	docker build -t orange-database .
	docker tag orange-database $(DOCKER_IMAGE_TAG)
	docker push $(DOCKER_IMAGE_TAG)

docker-build:
	@docker build -t $(DOCKER_IMAGE_TAG) .

docker-console:
	docker-compose run --publish=8765:8765 orange-database  /bin/bash

console: docker-console

build-console: docker-build docker-console

db-up:
	docker-compose up db

docker-up:
	docker-compose up

