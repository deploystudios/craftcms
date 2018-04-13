FROM php:7.2-fpm-alpine

LABEL maintainer="harald@urbantrout.io"

ENV COMPOSER_NO_INTERACTION=1

RUN set -ex \
    && apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev \
    && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-install -j${NPROC} zip \
    && docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j${NPROC} gd \
    && apk del freetype-dev libpng-dev libjpeg-turbo-dev

RUN set -ex \
    && apk add --update --no-cache autoconf g++ imagemagick-dev libtool make pcre-dev \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && apk del autoconf g++ libtool make pcre-dev

RUN set -ex \
    && apk add --no-cache postgresql-dev \
    && docker-php-ext-install pdo_pgsql

ADD php.ini /usr/local/etc/php/
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN chown -R www-data:www-data /var/www/html/
USER www-data
RUN composer create-project craftcms/craft /var/www/html
