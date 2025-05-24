FROM ubuntu:22.04

LABEL maintainer="Mariusz Milewczyk"

ENV LANG C.UTF-8

ARG TZ=UTC
ENV TZ ${TZ}
ENV GOSU_VERSION 1.17
ARG GPG_KEYS=177F4010FE56CA3336300305F1656F24C74CD1D8
ARG MARIADB_VERSION=11.2
ENV MARIADB_VERSION $MARIADB_VERSION

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql --home-dir /var/lib/mysql
RUN mkdir /docker-entrypoint-initdb.d && mkdir -p /var/mariadb/backup/


RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
  ca-certificates \
  gpg \
  curl \
  gpgv \
  libjemalloc2 \
  pwgen \
  tzdata \
  xz-utils \
  zstd ; \
  savedAptMark="$(apt-mark showmanual)"; \
  apt-get install -y --no-install-recommends \
  dirmngr \
  gpg-agent \
  wget; \
  rm -rf /var/lib/apt/lists/*; \
  dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
  wget -q -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
  wget -q -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
  GNUPGHOME="$(mktemp -d)"; \
  export GNUPGHOME; \
  gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
  for key in $GPG_KEYS; do \
  gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
  done; \
  gpg --batch --export "$GPG_KEYS" > /etc/apt/trusted.gpg.d/mariadb.gpg; \
  if command -v gpgconf >/dev/null; then \
  gpgconf --kill all; \
  fi; \
  gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
  gpgconf --kill all; \
  rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
  apt-mark auto '.*' > /dev/null; \
  [ -z "$savedAptMark" ] ||	apt-mark manual $savedAptMark >/dev/null; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  chmod +x /usr/local/bin/gosu; \
  gosu --version; \
  gosu nobody true

RUN curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash -s -- --mariadb-server-version=$MARIADB_VERSION
RUN apt-get update && apt-get install -y --no-install-recommends mariadb-server mariadb-backup mariadb-client mariadb-common socat && rm -rf /var/lib/apt/lists/* && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
RUN rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /run/mysqld && chown -R mysql:mysql /var/lib/mysql /run/mysqld && chmod 1777 /run/mysqld
RUN find /etc/mysql/ -name '*.cnf' -print0 | xargs -0 grep -lZE '^(bind-address|log|user\s)' | xargs -rt -0 sed -Ei 's/^(bind-address|log|user\s)/#&/';

VOLUME /var/lib/mysql

COPY scripts/mariadb/healthcheck.sh /usr/local/bin/healthcheck.sh
COPY scripts/mariadb/docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mariadbd"]

