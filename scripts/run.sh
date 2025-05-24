#!/bin/sh
docker-compose -f ./docker-compose.yml up -d certbot mariadb web phpmyadmin
