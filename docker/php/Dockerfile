FROM ubuntu:24.04

LABEL maintainer="Mariusz Milewczyk"

# PHP version is a build argument, so upgrading later is a one-line change in .env
ARG PHP_VERSION=8.4
ENV PHP_VERSION=${PHP_VERSION} \
  TZ=Europe/Warsaw \
  DEBIAN_FRONTEND=noninteractive \
  COMPOSER_ALLOW_SUPERUSER=0 \
  COMPOSER_HOME=/tmp/composer

# Base tools + nginx (official nginx.org repository)
RUN apt-get update && apt-get install -y --no-install-recommends \
  curl zip unzip procps telnet dnsutils supervisor gnupg2 ca-certificates \
  lsb-release ubuntu-keyring software-properties-common tzdata git && \
  curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
  > /usr/share/keyrings/nginx-archive-keyring.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" \
  > /etc/apt/sources.list.d/nginx.list && \
  apt-get update && apt-get install -y --no-install-recommends nginx && \
  rm -rf /var/lib/apt/lists/*

# PHP (ppa:ondrej/php)
RUN add-apt-repository -y ppa:ondrej/php && apt-get update && \
  apt-get install -y --no-install-recommends \
  php${PHP_VERSION}-cli \
  php${PHP_VERSION}-common \
  php${PHP_VERSION}-fpm \
  php${PHP_VERSION}-opcache \
  php${PHP_VERSION}-bcmath \
  php${PHP_VERSION}-curl \
  php${PHP_VERSION}-gd \
  php${PHP_VERSION}-imagick \
  php${PHP_VERSION}-intl \
  php${PHP_VERSION}-mbstring \
  php${PHP_VERSION}-mysql \
  php${PHP_VERSION}-pgsql \
  php${PHP_VERSION}-xml \
  php${PHP_VERSION}-zip && \
  rm -rf /var/lib/apt/lists/*

# Composer (official image, always the latest 2.x)
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# Configuration: nginx
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/conf.d /etc/nginx/conf.d/

# Configuration: PHP (custom ini for both FPM and CLI, own FPM config)
COPY config/php/php.ini /etc/php/${PHP_VERSION}/fpm/conf.d/99-custom.ini
COPY config/php/php.ini /etc/php/${PHP_VERSION}/cli/conf.d/99-custom.ini
COPY config/php/fpm-pool.conf /etc/php/${PHP_VERSION}/fpm/php-fpm.conf

# Configuration: supervisor (runs php-fpm + nginx)
COPY config/php/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /var/www/html

# Application
COPY --chown=www-data:www-data apps /var/www/html

# Processes run as www-data
RUN mkdir -p /etc/nginx/ssl && \
  chown -R www-data:www-data /var/www /run /var/log /etc/nginx/ssl
USER www-data

EXPOSE 80 443

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -fsS http://127.0.0.1/fpm-ping || exit 1

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
