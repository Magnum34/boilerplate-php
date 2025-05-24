#!make
ifneq (,$(wildcard ./.env))
	include .env
	NOW_DATE=$(shell date +'%y%m%d-%H%M')
	BACKUP_FULLNAME="${DATABASE_NAME}-${NOW_DATE}.sql"
endif

help:
	@echo ''
	@echo 'Usage: make [TARGET]'
	@echo 'Targets:'
	@echo '  init   quick creation of a development environment'
	@echo '  build    build images'
	@echo '  rebuild  rebuild images'
	@echo '  run      run all containers'
	@echo '  stop     stop all containers'
	@echo '  status   status all containers'
	@echo '  logs     logs all containers'
	@echo '  mariadb_export export database'
	@echo '  mariadb_shell connect with database'

init_env:
	cp .env.example .env

init: init_env build run wordpress_install
	echo "Done"

build:
	bash  ./scripts/build.sh

rebuild:
	docker-compose -f ./docker-compose.yml build --no-cache certbot mariadb web

run:
	bash  ./scripts/run.sh

stop:
	bash ./scripts/stop.sh

status:
	bash ./scripts/status.sh

monitor:
	bash ./scripts/monitor.sh

mariadb_shell:
	docker-compose -f ./docker-compose.yml exec -it mariadb mariadb -u ${DATABASE_USER} -P ${MARIADB_PORT} -p ${DATABASE_NAME}

mariadb_export:
	docker-compose -f ./docker-compose.yml exec -it mariadb mariadb-dump -u ${DATABASE_USER} -P ${MARIADB_PORT} -p ${DATABASE_NAME} > ${BACKUP_FULLNAME}

logs:
	bash ./scripts/logs.sh
