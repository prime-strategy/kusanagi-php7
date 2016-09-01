#//----------------------------------------------------------------------------
#// PHP7 FastCGI Server ( for KUSANAGI Runs on Docker )
#//----------------------------------------------------------------------------
FROM php:7.0.10-fpm-alpine
MAINTAINER kusanagi@prime-strategy.co.jp

# Environment variable
ENV MYSQL_VERSION 10.1.14-r3
ENV APCU_VERSION 5.1.5
ENV APCU_BC_VERSION 1.0.3

RUN apk update \
	&& apk add --no-cache --virtual .build-php \
		$PHPIZE_DEPS \
		mysql=$MYSQL_VERSION \
	&& docker-php-ext-install \
		mysqli \
		opcache \
	&& pecl install apcu-$APCU_VERSION \
	&& docker-php-ext-enable apcu \
	&& pecl install apcu_bc-$APCU_BC_VERSION \
	&& docker-php-ext-enable apc \
	&& apk del .build-php

COPY files/*.ini /usr/local/etc/php/conf.d/
RUN mkdir -p /etc/php.d/
COPY files/opcache*.blacklist /etc/php.d/
