# Boilerplate PHP

A ready-to-use Docker environment for building PHP applications:
**PHP 8.4 (FPM) + Nginx + MariaDB + phpMyAdmin**, with local HTTPS out of the box.

## Stack

| Service      | Version            | Host port (default) | Notes                                  |
|--------------|--------------------|---------------------|----------------------------------------|
| `web`        | PHP 8.4 + Nginx    | `80`, `443`         | Ubuntu 24.04, PHP from `ppa:ondrej/php`, Composer 2 |
| `mariadb`    | MariaDB 11.2       | `3306`              | Data kept in the `db_data` volume      |
| `phpmyadmin` | phpMyAdmin 5       | `8080`              | Connects to `mariadb` automatically    |
| `certbot`    | one-shot           | –                   | Generates self-signed certs for `localhost` |

PHP extensions: `bcmath`, `curl`, `gd`, `imagick`, `intl`, `mbstring`, `mysql` (PDO + mysqli),
`opcache`, `pgsql`, `xml`, `zip`.

## Requirements

- Docker Engine with the Compose v2 plugin (`docker compose`), e.g. [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- `make`
- On Linux: your user in the `docker` group

## Quick start

```bash
git clone <repo-url> my-app && cd my-app
make init
```

`make init` creates `.env` from `.env.example`, builds the images and starts the stack. Then open:

- App: <http://localhost> / <https://localhost> (self-signed certificate)
- phpMyAdmin: <http://localhost:8080>

Your code lives in [`apps/`](apps/) and is mounted into the container at `/var/www/html`,
so changes are visible immediately — no rebuild needed.

## Everyday commands

Run `make` to see the full list. The most useful ones:

| Command                                  | What it does                                  |
|------------------------------------------|-----------------------------------------------|
| `make up` / `make down`                  | Start / stop the stack                        |
| `make restart`                           | Restart everything                            |
| `make ps`                                | Container status                              |
| `make logs` / `make logs s=web`          | Follow logs (all or one service)              |
| `make shell` / `make shell s=mariadb`    | Shell inside a container (`web` by default)   |
| `make php c="-v"`                        | Run PHP CLI                                   |
| `make composer c="require monolog/monolog"` | Run Composer inside the container          |
| `make php-version`                       | PHP version and loaded extensions             |
| `make db-shell`                          | MariaDB client as the application user        |
| `make db-export`                         | Dump the database to `backups/<db>-<date>.sql`|
| `make db-import f=backups/dump.sql`      | Import an SQL dump                            |
| `make build` / `make rebuild`            | Build images / rebuild without cache          |
| `make clean`                             | Remove containers **and database volumes**    |

Old target names (`run`, `stop`, `status`, `mariadb_shell`, `mariadb_export`) still work as aliases.

## Configuration

All settings live in `.env` (see [`.env.example`](.env.example)):

| Variable                  | Default            | Description                              |
|---------------------------|--------------------|------------------------------------------|
| `APP_NAME`                | `boilerplate-php`  | Compose project name and image prefix    |
| `VERSION`                 | `2.0.0`            | Tag of the built images                  |
| `PHP_VERSION`             | `8.4`              | PHP version installed in the `web` image |
| `HTTP_PORT` / `HTTPS_PORT`| `80` / `443`       | Host ports for Nginx                     |
| `PHPMYADMIN_PORT`         | `8080`             | Host port for phpMyAdmin                 |
| `MARIADB_PORT`            | `3306`             | Host port for MariaDB                    |
| `DATABASE_NAME`           | `example`          | Database created on first start          |
| `DATABASE_USER` / `DATABASE_PASSWORD` | `example` | Application DB user (must not be `root`) |
| `DATABASE_ROOT_PASSWORD`  | `root`             | MariaDB root password                    |

Inside the `web` container the database connection is available as environment variables:
`DB_HOST=mariadb`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`.

```php
$pdo = new PDO(
    sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4', getenv('DB_HOST'), getenv('DB_PORT'), getenv('DB_DATABASE')),
    getenv('DB_USERNAME'),
    getenv('DB_PASSWORD'),
);
```

### Changing the PHP version

Set `PHP_VERSION` in `.env` (any version from `ppa:ondrej/php`, e.g. `8.3`) and run `make rebuild && make restart`.

### Custom PHP / Nginx / MariaDB config

| File                                   | Purpose                                      |
|----------------------------------------|----------------------------------------------|
| `config/php/php.ini`                   | PHP settings (loaded for FPM and CLI)        |
| `config/php/fpm-pool.conf`             | PHP-FPM pool                                 |
| `config/php/supervisord.conf`          | Processes in the `web` container             |
| `config/nginx/nginx.conf`              | Global Nginx config (baked into the image)   |
| `config/nginx/conf.d/default.conf`     | Virtual host (mounted, change + `make restart`) |
| `config/mariadb/my.cnf`                | MariaDB server settings                      |
| `config/mariadb/docker-entrypoint-initdb.d/` | `*.sql`, `*.sql.gz`, `*.sh` run on the **first** DB start |

Changes to files baked into the image (`php.ini`, `fpm-pool.conf`, `supervisord.conf`, `nginx.conf`)
require `make build && make restart`.

## Project structure

```
apps/        your application code (document root)
config/      PHP, Nginx and MariaDB configuration
docker/      Dockerfiles (php, mariadb, certbot)
scripts/     helper scripts used inside the images
certs/       generated certificates (git-ignored)
backups/     database dumps from make db-export (git-ignored)
```

## Production notes

- Set strong passwords in `.env` and don't expose `MARIADB_PORT` / phpMyAdmin publicly.
- In `config/php/php.ini` set `opcache.validate_timestamps = 0`.
- Let's Encrypt certificates: see `scripts/certbot/run-production.sh`.
