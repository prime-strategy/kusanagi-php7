#//----------------------------------------------------------------------------
#// PHP7 FastCGI Server ( for KUSANAGI Runs on Docker )
#//----------------------------------------------------------------------------
<<<<<<< HEAD
FROM php:7.0.16-fpm-alpine
MAINTAINER kusanagi@prime-strategy.co.jp

# Environment variable
ARG MYSQL_VERSION=10.1.26-r0
ARG APCU_VERSION=5.1.8
ARG APCU_BC_VERSION=1.0.3
ARG PHP_VERSION=7.0.16-r0
=======
FROM php:7.2.12-fpm-alpine
MAINTAINER kusanagi@prime-strategy.co.jp

# Environment variable
ARG MYSQL_VERSION=10.2.15-r0
ARG APCU_VERSION=5.1.13
ARG APCU_BC_VERSION=1.0.4
>>>>>>> release/7.2.12

		#libtool autoconf automake \
RUN apk update \
	&& apk add --no-cache \
		libbz2 \
		gd \
		gettext \
		libmcrypt \
		libxslt \
	&& apk add --no-cache --virtual .build-php \
		$PHPIZE_DEPS \
<<<<<<< HEAD
		mariadb=$MYSQL_VERSION \
		mariadb-dev=$MYSQL_VERSION \
		gd-dev \
		jpeg-dev \
		libpng-dev \
		libwebp-dev \
		libxpm-dev \
		zlib-dev \
		freetype-dev \
		bzip2-dev \
		libexif-dev \
		xmlrpc-c-dev \
		pcre-dev \
		gettext-dev \
		libmcrypt-dev \
		libxslt-dev \
=======
		mysql=$MYSQL_VERSION \
		pcre-dev \
	&& docker-php-ext-install \
		mysqli \
		opcache \
	&& pecl channel-update pecl.php.net \
>>>>>>> release/7.2.12
	&& pecl install apcu-$APCU_VERSION \
	&& pecl install apcu_bc-$APCU_BC_VERSION \
<<<<<<< HEAD
	&& docker-php-ext-enable apc \
	&& docker-php-ext-configure gd --with-jpeg-dir=/usr \
	&& docker-php-ext-install \
		mysqli \
		opcache \
		gd \
		bz2 \
		pdo pdo_mysql \
		bcmath exif gettext mcrypt pcntl \
		soap sockets sysvsem sysvshm xmlrpc xsl zip \
=======
	&& docker-php-ext-enable apcu apc \
>>>>>>> release/7.2.12
	&& apk del .build-php \
	&& rm -f /usr/local/etc/php/conf.d/docker-php-ext-apc.ini \
	&& rm -f /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini \
	&& rm -f /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
	&& mkdir -p /etc/php.d/

COPY files/*.ini /usr/local/etc/php/conf.d/
COPY files/opcache*.blacklist /etc/php.d/
