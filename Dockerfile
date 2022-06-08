FROM debian:bullseye-slim as base

ENV PHP_CONF_DATE_TIMEZONE=UTC \
    PHP_CONF_MAX_EXECUTION_TIME=60 \
    PHP_CONF_MEMORY_LIMIT=512M \
    PHP_CONF_OPCACHE_VALIDATE_TIMESTAMP=0 \
    PHP_CONF_MAX_INPUT_VARS=1000 \
    PHP_CONF_UPLOAD_LIMIT=40M \
    PHP_CONF_MAX_POST_SIZE=40M

RUN echo 'APT::Install-Recommends "0" ; APT::Install-Suggests "0" ;' > /etc/apt/apt.conf.d/01-no-recommended && \
    echo 'path-exclude=/usr/share/man/*' > /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    echo 'path-exclude=/usr/share/doc/*' >> /etc/dpkg/dpkg.cfg.d/path_exclusions && \
    apt-get update && \
    apt-get --yes install apt-transport-https ca-certificates curl wget &&\
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg &&\
    sh -c 'echo "deb https://packages.sury.org/php/ bullseye main" > /etc/apt/sources.list.d/php.list' &&\
    apt-get update && \
    apt-get --yes install imagemagick \
        libmagickcore-6.q16-6-extra \
        ghostscript \
        php8.0-fpm \
        php8.0-cli \
        php8.0-intl \
        php8.0-opcache \
        php8.0-mysql \
        php8.0-zip \
        php8.0-xml \
        php8.0-gd \
        php8.0-curl \
        php8.0-mbstring \
        php8.0-bcmath \
        php8.0-imagick \
        php8.0-apcu \
        php8.0-exif \
        php8.0-memcached \
        php8.0-soap \
        openssh-client \
        aspell \
        aspell-en aspell-es aspell-de aspell-fr && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/sbin/php-fpm8.0 /usr/local/sbin/php-fpm && \
    usermod --uid 1000 www-data && groupmod --gid 1000 www-data && \
    mkdir /srv/magento && \
    sed -i "s#listen = /run/php/php8.0-fpm.sock#listen = 9000#g" /etc/php/8.0/fpm/pool.d/www.conf && \
    mkdir -p /run/php

COPY docker/magento.ini /etc/php/8.0/cli/conf.d/99-magento.ini
COPY docker/magento.ini /etc/php/8.0/fpm/conf.d/99-magento.ini

FROM base as dev

ENV PHP_CONF_OPCACHE_VALIDATE_TIMESTAMP=1
ENV COMPOSER_MEMORY_LIMIT=4G

RUN apt-get update && \
    apt-get --yes install gnupg &&\
    apt-get update && \
    apt-get --yes install \
        curl \
        default-mysql-client \
        git \
        perceptualdiff \
        procps \
        unzip &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

RUN mkdir -p /var/www/.composer && chown www-data:www-data /var/www/.composer
RUN mkdir -p /var/www/.cache && chown www-data:www-data /var/www/.cache

VOLUME /srv/magento