FROM ubuntu:24.04

LABEL maintainer="Mariusz Milewczyk"

ENV TZ=Europe/Warsaw


# nginx
RUN apt-get update && apt-get install -y  curl zip unzip procps  telnet dnsutils monit supervisor gnupg2 ca-certificates lsb-release ubuntu-keyring ca-certificates software-properties-common && \
  curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
  | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null &&  \
  gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
  http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
  |  tee /etc/apt/sources.list.d/nginx.list && apt update && apt install -y nginx && rm -rf /var/lib/apt/lists/* && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# PHP
RUN add-apt-repository -y ppa:ondrej/php && apt-get update && \
  apt-get install -y php8.2 php8.2-common php8.2-cli \
  php8.2-ctype \
  php8.2-zip \
  php8.2-curl \
  php8.2-dom \
  php8.2-fileinfo \
  php8.2-fpm \
  php8.2-pgsql \
  php8.2-gd \
  php8.2-intl \
  php8.2-mbstring \
  php8.2-xml \
  php8.2-zip \
  php8.2-gd \
  php8.2-mysql \
  php8.2-imagick \
  php8.2-xmlrpc && \
  rm -rf /var/lib/apt/lists/* && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

# composer
RUN HASH=`curl -sS https://composer.github.io/installer.sig` && curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php && \
  php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
  php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer


WORKDIR /var/www/html

# Make sure files/folders needed by the processes are accessable when they run under the www-data user
RUN chown -R www-data:www-data /var/www/html /run  /var/log /var/www
USER www-data

# Configuration Nginx
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/conf.d /etc/nginx/conf.d/

# Configuration PHP
COPY config/php8.2/php.ini /etc/php82/conf.d/custom.ini
COPY config/php8.2/fpm-pool.conf /etc/php82/php-fpm.d/www.conf

# Configuration supervisor
COPY config/php8.2/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# COPY application
COPY --chown=www-data /apps /var/www/html



EXPOSE 80 443
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]




