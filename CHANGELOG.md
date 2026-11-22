# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [2.0.0] - 22.11.2026

### Changed
- PHP 8.2 -> PHP 8.4; version is now a build argument (`PHP_VERSION` in `.env`)
- `docker/php8.2`, `config/php8.2` renamed to `docker/php`, `config/php`
- PHP config is now loaded from the correct Ubuntu paths (`/etc/php/<ver>/...`)
- Composer installed from the official `composer:2` image
- Makefile rewritten: self-documenting `make help`, `docker compose` v2, new targets
  (`up`, `down`, `restart`, `logs s=`, `shell`, `php`, `composer`, `db-import`, `clean`)
- Nginx: `http2 on;` instead of the deprecated `listen ... http2`
- README rewritten

### Fixed
- phpMyAdmin could not reach MariaDB (different network)
- `make init` referenced a non-existent `wordpress_install` target
- `make mariadb_export` produced broken dumps (TTY) and used the host port inside the container
- `web` now waits for healthy MariaDB and generated certificates

### Removed
- `scripts/{build,run,stop,status,logs,monitor}.sh` (replaced by Makefile targets)

## [1.0.0] - 24.05.2025

- Added boilerplate PHP 8.2
