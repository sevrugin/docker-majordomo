THIS_FILE := $(lastword $(MAKEFILE_LIST))
#envs
cnf ?= .env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

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
	@ rm -rf app data
init-app:
	@ if [ ! -d "./app" ]; then \
		echo "Make app folder\n"; \
		mkdir -p ./app; \
		git clone -b alpha https://github.com/sergejey/majordomo.git ./app; \
	fi
	@ if [ ! -f ./app/config.php ]; then \
		cp ./app/config.php.sample ./app/config.php; \
	fi

init-db:
	@ if [ ! -d "./app" ]; then \
		echo "run 'make init-app' first\n"; \
		exit 1; \
	fi
	@ if [ ! -d "./data" ]; then \
		mkdir -p ./data; \
		touch wait-for-db; \
	fi
	@ docker-compose up -d mysqldb
	@ if [ -f "./wait-for-db" ]; then \
		rm wait-for-db; \
		sleep 10; \
	fi
	@ docker-compose exec mysqldb mysql -p$(MYSQL_ROOT_PASSWORD) -e "DROP DATABASE IF EXISTS $(DB_DATABASE);"
	@ docker-compose exec mysqldb mysql -p$(MYSQL_ROOT_PASSWORD) -e "CREATE DATABASE $(DB_DATABASE);"
	@ docker-compose exec mysqldb mysql -p$(MYSQL_ROOT_PASSWORD) -e "DROP USER IF EXISTS $(DB_USERNAME)@'%';"
	@ docker-compose exec mysqldb mysql -p$(MYSQL_ROOT_PASSWORD) -e "CREATE USER IF NOT EXISTS $(DB_USERNAME)@'%' IDENTIFIED BY '$(DB_PASSWORD)';"
	@ docker-compose exec mysqldb mysql -p$(MYSQL_ROOT_PASSWORD) -e "GRANT ALL ON $(DB_DATABASE).* TO $(DB_USERNAME)@'%'"
	@ docker-compose exec mysqldb mysql -p$(MYSQL_ROOT_PASSWORD) -e "GRANT RELOAD ON *.* TO $(DB_USERNAME)@'%'"
	@ docker-compose exec mysqldb mysql -p$(MYSQL_ROOT_PASSWORD) -e "FLUSH PRIVILEGES"
	@ cat ./app/db_terminal.sql | docker-compose exec -T mysqldb mysql -p$(MYSQL_ROOT_PASSWORD) $(DB_DATABASE)

pull: ## git pull cod
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
	@$(call docker_compose, exec php bash)


%:
    @:
define docker_compose
    @docker-compose -f ./docker-compose.yml $(1)
endef
