#!make
# ----------------------------------------------------------------------------
#  Boilerplate PHP — developer commands
#  Run `make` (or `make help`) to list everything that is available.
# ----------------------------------------------------------------------------

SHELL := /bin/bash
.DEFAULT_GOAL := help

ifneq (,$(wildcard ./.env))
include .env
export
endif

COMPOSE     ?= docker compose
DC          := $(COMPOSE) -f ./docker-compose.yml
WEB         := web
DB          := mariadb
s           ?=
NOW_DATE    := $(shell date +'%y%m%d-%H%M')
BACKUP_DIR  := backups
BACKUP_FILE ?= $(BACKUP_DIR)/$(DATABASE_NAME)-$(NOW_DATE).sql

C_INFO  := \033[36m
C_OK    := \033[32m
C_WARN  := \033[33m
C_RESET := \033[0m

##@ Help

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make $(C_INFO)<target>$(C_RESET) [s=<service>] [c=\"<args>\"]\n"} \
		/^[a-zA-Z0-9_-]+:.*?##/ { printf "  $(C_INFO)%-18s$(C_RESET) %s\n", $$1, $$2 } \
		/^##@/ { printf "\n$(C_WARN)%s$(C_RESET)\n", substr($$0, 5) }' $(MAKEFILE_LIST)
	@echo ""

##@ Setup

.PHONY: init
init: env dirs build up ## First run: create .env, build images and start the stack
	@echo -e "$(C_OK)Ready!$(C_RESET)"
	@echo "  App:        http://localhost:$(or $(HTTP_PORT),80)  |  https://localhost:$(or $(HTTPS_PORT),443)"
	@echo "  phpMyAdmin: http://localhost:$(or $(PHPMYADMIN_PORT),8080)"

.PHONY: env
env: ## Create .env from .env.example (does not overwrite an existing one)
	@if [ -f .env ]; then \
		echo -e "$(C_WARN).env already exists, skipping$(C_RESET)"; \
	else \
		cp .env.example .env && echo -e "$(C_OK).env created from .env.example$(C_RESET)"; \
	fi

.PHONY: dirs
dirs:
	@mkdir -p certs/development certs/production $(BACKUP_DIR)

##@ Docker

.PHONY: build
build: ## Build images
	$(DC) build

.PHONY: rebuild
rebuild: ## Rebuild images from scratch (no cache, fresh base images)
	$(DC) build --no-cache --pull

.PHONY: up
up: dirs ## Start all containers in the background
	$(DC) up -d

.PHONY: down
down: ## Stop and remove containers (data volumes are kept)
	$(DC) down

.PHONY: restart
restart: down up ## Restart the whole stack

.PHONY: ps
ps: ## Show container status
	$(DC) ps

.PHONY: logs
logs: ## Follow logs (all, or one service: make logs s=web)
	$(DC) logs -f --tail=100 $(s)

.PHONY: monitor
monitor: ## Live CPU / memory usage of containers
	docker stats

.PHONY: clean
clean: ## Stop containers and DELETE volumes (database data!)
	@read -p "This removes all containers AND database volumes. Continue? [y/N] " ans && [ "$${ans:-N}" = y ]
	$(DC) down -v --remove-orphans

##@ PHP

.PHONY: shell
shell: ## Open a shell in the web container (make shell s=mariadb for another one)
	$(DC) exec $(or $(s),$(WEB)) bash

.PHONY: php
php: ## Run PHP CLI: make php c="-v"
	$(DC) exec $(WEB) php $(c)

.PHONY: composer
composer: ## Run Composer: make composer c="require monolog/monolog"
	$(DC) exec $(WEB) composer $(c)

.PHONY: php-version
php-version: ## Show PHP version and loaded extensions
	$(DC) exec $(WEB) php -v
	$(DC) exec $(WEB) php -m

##@ Database

.PHONY: db-shell
db-shell: ## Open MariaDB client as the application user
	$(DC) exec -e MYSQL_PWD="$(DATABASE_PASSWORD)" $(DB) mariadb -u "$(DATABASE_USER)" "$(DATABASE_NAME)"

.PHONY: db-export
db-export: dirs ## Dump database to backups/ (or BACKUP_FILE=path.sql)
	$(DC) exec -T -e MYSQL_PWD="$(DATABASE_ROOT_PASSWORD)" $(DB) \
		mariadb-dump -u root --single-transaction --routines --triggers "$(DATABASE_NAME)" > "$(BACKUP_FILE)"
	@echo -e "$(C_OK)Saved $(BACKUP_FILE)$(C_RESET)"

.PHONY: db-import
db-import: ## Import an SQL file: make db-import f=backups/dump.sql
	@test -n "$(f)" || { echo -e "$(C_WARN)Usage: make db-import f=path/to/dump.sql$(C_RESET)"; exit 1; }
	$(DC) exec -T -e MYSQL_PWD="$(DATABASE_ROOT_PASSWORD)" $(DB) mariadb -u root "$(DATABASE_NAME)" < "$(f)"
	@echo -e "$(C_OK)Imported $(f)$(C_RESET)"

# ----------------------------------------------------------------------------
# Backwards-compatible aliases (old target names)
# ----------------------------------------------------------------------------
.PHONY: run stop status init_env mariadb_shell mariadb_export
run: up
stop: down
status: ps
init_env: env
mariadb_shell: db-shell
mariadb_export: db-export
