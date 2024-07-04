ARG flavor=bullseye

FROM php:8.2-cli-${flavor}

LABEL maintainer="Tobias Munk <tobias@diemeisterei.de>"

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN set -eux; \
    install-php-extensions \
        php82-bcmath \
        php82-mysqli \
        php82-pdo php82-pdo_mysql php82-pdo_pgsql \
        php82-soap \
        php82-sockets \
        php82-zip \
        php82-pecl-apcu-stable \
        php82-pecl-memcached-stable \
        php82-pecl-mongodb-stable \
        php82-pecl-xdebug-stable \
        # and composer \
        @composer; \
    # Configure php \
    echo "date.timezone = UTC" >> /usr/local/etc/php/php.ini;
RUN pecl install apcu \
    && pecl install memcached \
    && pecl install mongodb \
	&& pecl install xdebug \
	&& docker-php-ext-enable apcu memcached mongodb xdebug

ENV COMPOSER_ALLOW_SUPERUSER '1'

WORKDIR /codecept

# Install codeception
RUN set -eux; \
    composer require --no-update \
        codeception/codeception \
        codeception/module-apc \
        codeception/module-asserts \
        codeception/module-cli \
        codeception/module-db \
        codeception/module-filesystem \
        codeception/module-ftp \
        codeception/module-memcache \
        codeception/module-mongodb \
        codeception/module-phpbrowser \
        codeception/module-redis \
        codeception/module-rest \
        codeception/module-sequence \
        codeception/module-soap \
        codeception/module-webdriver; \
    composer update --no-dev --prefer-dist --no-interaction --optimize-autoloader --apcu-autoloader; \
    ln -s /codecept/vendor/bin/codecept /usr/local/bin/codecept; \
    mkdir /project;

ENTRYPOINT ["codecept"]

# Prepare host-volume working directory
WORKDIR /project
