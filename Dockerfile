#//----------------------------------------------------------------------------
#// PHP7 FastCGI Server ( for KUSANAGI Runs on Docker )
#//----------------------------------------------------------------------------
FROM php:7.3.0-fpm-alpine
MAINTAINER kusanagi@prime-strategy.co.jp

# Environment variable
ARG MYSQL_VERSION=10.2.15-r0
ARG APCU_VERSION=5.1.13
ARG APCU_BC_VERSION=1.0.4

		#libtool autoconf automake \
RUN apk update \
	&& apk add --no-cache \
		libbz2 \
		gd \
		zip \
		libzip \
		gettext \
		libxslt \
		c-client \
		libxpm \
		libldap \
		libpq \
	&& apk add --update --no-cache --virtual .build-php \
		$PHPIZE_DEPS \
		mariadb=$MYSQL_VERSION \
		mariadb-dev=$MYSQL_VERSION \
		postgresql \
		postgresql-dev \
		gd-dev \
		jpeg-dev \
		libpng-dev \
		libwebp-dev \
		libxpm-dev \
		zlib-dev \
		libzip-dev \
		freetype-dev \
		bzip2-dev \
		libexif-dev \
		xmlrpc-c-dev \
		pcre-dev \
		gettext-dev \
		libxslt-dev \
		pcre-dev \
		openldap-dev \
		imap-dev \
	&& pecl channel-update pecl.php.net \
	&& docker-php-ext-configure gd --with-jpeg-dir=/usr/include \
		--with-xpm-dir=/usr/include --with-webp-dir=/usr/include \
		--with-png-dir=/usr/include --with-freetype-dir=/usr/include/ \
		--enable-gd-jis-conv \
	&& docker-php-ext-install \
		mysqli pgsql \
		opcache \
		gd \
		calendar \
		imap ldap \
		bz2 zip \
		pdo pdo_mysql pdo_pgsql \
		bcmath exif gettext pcntl \
		soap sockets sysvsem sysvshm xmlrpc xsl \
	&& pecl install apcu-$APCU_VERSION \
	&& pecl install apcu_bc-$APCU_BC_VERSION \
	&& docker-php-ext-enable apcu apc \
	&& apk del .build-php \
	&& rm -f /usr/local/etc/php/conf.d/docker-php-ext-apc.ini \
	&& rm -f /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini \
	&& rm -f /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
	&& mkdir -p /etc/php.d/

COPY files/*.ini /usr/local/etc/php/conf.d/
COPY files/opcache*.blacklist /etc/php.d/
