FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -yqq && apt-get install -yqq software-properties-common > /dev/null
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php > /dev/null && \
    apt-get update -yqq > /dev/null && apt-get upgrade -yqq > /dev/null

RUN apt-get install -yqq git unzip \
    php8.2-cli php8.2-pgsql php8.2-mbstring php8.2-xml php8.2-curl > /dev/null

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN apt-get install -y php-pear php8.2-dev libevent-dev > /dev/null
RUN pecl install event-3.0.8 > /dev/null && echo "extension=event.so" > /etc/php/8.2/cli/conf.d/event.ini

EXPOSE 8080

ADD . /symfony
WORKDIR /symfony

RUN mkdir -m 777 -p /symfony/var/cache/{dev,prod} /symfony/var/log

ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --optimize-autoloader --classmap-authoritative --no-dev --quiet --no-scripts
RUN cp deploy/postgresql/.env . && composer dump-env prod && bin/console cache:clear

COPY deploy/conf/cli-php.ini /etc/php/8.2/cli/php.ini

CMD php server.php start
