#!/bin/sh
docker-compose -f ./docker-compose.yml build certbot mariadb web phpmyadmin
