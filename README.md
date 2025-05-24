# Boilerplate PHP

## Requirements

- docker and docker-compose

  > Detailed instructions for setup of docker can be found [here](https://www.docker.com/community-edition).

- user added to `docker` group

## Exposed services in Production/Staging environment

- Nginx stable version 1.24  at ports 80/443
- MariaDB version 11.2 at port 3306
- PHP version 8.2

## Initial setup of project

The Makefile is suited to compress the basic docker commands for building and running containers. You can do things like this:
```
# build the whole thing
make build

make help
# Usage: make [TARGET]
# Targets:
# build    build images
#  rebuild  rebuild images
#  run      run all containers
#  stop     stop all containers
#  status   status all containers
#  logs     logs all containers
#  mariadb_export export database
#  mariadb_shell connect with database
