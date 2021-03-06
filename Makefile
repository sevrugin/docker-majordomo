#!/bin/bash
THIS_FILE := $(lastword $(MAKEFILE_LIST))
#envs
cnf ?= .env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# Colors
NO_COLOR?=\x1b[0m
OK_COLOR?=\x1b[32;01m
ERROR_COLOR?=\x1b[31;01m
WARN_COLOR?=\x1b[33;01m

ECHO?=/bin/echo -e
SED?=/bin/sed -i

#guid/uid
export UID = $(shell id -u)
export GID = $(shell id -g)

#vars
APP_PATH=./app
DB_DUMP_FILE=./app/db_terminal.sql
.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

clean:
	@ printf '$(ERROR_COLOR)Cleaning folder...$(NO_COLOR)'
	@ sudo rm -rf app data logs
	@ printf '\t\t\t\t$(OK_COLOR)[OK]$(NO_COLOR)\n'

init-all: init-app init-db ## Init all project

init-app: ## Init app folder
	@ if [ ! -d "./app" ]; then \
		$(ECHO) -n 'Make app folder...'; \
		mkdir -p ./app; \
		$(ECHO) '\t\t\t\t$(OK_COLOR)[OK]$(NO_COLOR)'; \
		$(ECHO) -n 'Clone majordomo repository...'; \
		$(ECHO) '\t\t\t$(OK_COLOR)[OK]$(NO_COLOR)'; \
		git clone -b alpha https://github.com/sergejey/majordomo.git ./app; \
	fi
	@ if [ ! -f ./app/config.php ]; then \
		$(ECHO) -n 'Make app/config.php...'; \
		cp ./app/config.php.sample ./app/config.php; \
		$(SED) "s/'DB_HOST', 'localhost'/'DB_HOST', \$$_ENV['MYSQL_HOST']/g" ./app/config.php; \
		$(SED) "s/'DB_NAME', 'db_terminal'/'DB_NAME', \$$_ENV['MYSQL_DATABASE']/g" ./app/config.php; \
		$(SED) "s/'DB_USER', 'root'/'DB_USER', \$$_ENV['MYSQL_USER']/g" ./app/config.php; \
		$(SED) "s/'DB_PASSWORD', ''/'DB_PASSWORD', \$$_ENV['MYSQL_PASSWORD']/g" ./app/config.php; \
		$(ECHO) '\t\t\t\t$(OK_COLOR)[OK]$(NO_COLOR)'; \
	fi

init-db: ## Init database
	@ if [ ! -d "./app" ]; then \
		$(ECHO) '$(WARN_COLOR)"app" folder not found. Run `make init-app` first$(NO_COLOR)'; \
		exit 1; \
	fi
	@ if [ ! -d "./data" ]; then \
		mkdir -p ./data; \
	fi
	@$(ECHO) -n 'Starting "mysqldb"...'
	@ docker-compose up -d mysqldb > /dev/null 2>&1
	@ while ! docker ps | grep mysqldb > /dev/null 2>&1; do sleep 1; done
	@$(ECHO) '\t\t\t\t$(OK_COLOR)[OK]$(NO_COLOR)'

	@$(ECHO) -n 'Creating DB, User and previlegies...'
	@ docker-compose exec mysqldb bash -c 'while ! mysql -p$(MYSQL_ROOT_PASSWORD) -e "SHOW DATABASES" > /dev/null 2>&1; do sleep 1; done && \
		mysql -p$(MYSQL_ROOT_PASSWORD) -e "DROP DATABASE IF EXISTS $(DB_DATABASE); \
		CREATE DATABASE $(DB_DATABASE); \
		DROP USER IF EXISTS $(DB_USERNAME)@\"%\"; \
		CREATE USER IF NOT EXISTS $(DB_USERNAME)@\"%\" IDENTIFIED BY \"$(DB_PASSWORD)\"; \
		GRANT ALL ON $(DB_DATABASE).* TO $(DB_USERNAME)@\"%\"; \
		GRANT RELOAD ON *.* TO $(DB_USERNAME)@\"%\"; \
		FLUSH PRIVILEGES; \
		"'
	@$(ECHO) '\t\t$(OK_COLOR)[OK]$(NO_COLOR)'

	@$(ECHO) -n 'Loading dump file...'
	@ cat ./app/db_terminal.sql | docker-compose exec -T mysqldb mysql -p$(MYSQL_ROOT_PASSWORD) $(DB_DATABASE)
	@$(ECHO) '\t\t\t\t$(OK_COLOR)[OK]$(NO_COLOR)'
	@ docker-compose rm -sf mysqldb > /dev/null 2>&1 &

pull: ## git pull majordomo code
	@ cd ./app | git pull
build: ## Build docker containers
	@$(call docker_compose, build)
up: ## Up docker containers
	@$(call docker_compose, up -d)

stop: ## Stop docker containers
	@$(call docker_compose, stop)

restart: ## Restart docker containers
	@$(call docker_compose, restart)

ps: ## Ps docker containers
	@$(call docker_compose, ps)

exec-mysql: ## Enter to mysql container
	@$(call docker_compose, exec mysqldb bash)

exec-app: ## Enter to app container
	@$(call docker_compose, exec --user 1000 php bash)


%:
    @:
define docker_compose
    @docker-compose -f ./docker-compose.yml $(1)
endef
