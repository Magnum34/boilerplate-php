#!/bin/sh
docker-compose -f ./docker-compose.yml down certbot mariadb web phpmyadmin
