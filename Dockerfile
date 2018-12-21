#//----------------------------------------------------------------------------
#// PHP7 FastCGI Server ( for KUSANAGI Runs on Docker )
#//----------------------------------------------------------------------------
FROM php:7.3.0-fpm-alpine
MAINTAINER kusanagi@prime-strategy.co.jp

# Environment variable
ARG MYSQL_VERSION=10.2.15-r0
ARG APCU_VERSION=5.1.13
ARG APCU_BC_VERSION=1.0.4

# add user
RUN : \
	&& apk update && \
	apk upgrade && \
	apk add --virtual .user shadow \
	&& groupadd -g 1001 www \
	&& useradd -d /var/lib/www -s /bin/nologin -g www -M -u 1001 httpd \
	&& apk del --purge .user \
	&& :

RUN apk update \
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
		icu-dev \
	&& pecl channel-update pecl.php.net \
	&& docker-php-ext-configure gd --with-jpeg-dir=/usr/include \
		--with-xpm-dir=/usr/include --with-webp-dir=/usr/include \
		--with-png-dir=/usr/include --with-freetype-dir=/usr/include/ \
		--enable-gd-jis-conv \
	&& docker-php-ext-install \
		mysqli pgsql \
		opcache \
		gd \
		intl \
		calendar \
		imap ldap \
		bz2 zip \
		pdo pdo_mysql pdo_pgsql \
		bcmath exif gettext pcntl \
		soap sockets sysvsem sysvshm xmlrpc xsl \
	&& pecl install apcu-$APCU_VERSION \
	&& pecl install apcu_bc-$APCU_BC_VERSION \
	&& docker-php-ext-enable apcu apc \
	&& strip /usr/local/lib/php/extensions/no-debug-non-zts-20180731/*.so \
	&& runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' /usr/local/bin/php /usr/local/lib/php/extensions/no-debug-non-zts-20180731/*.so \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apk add --no-cache --virtual .php7-rundeps $runDeps \
	&& apk del .build-php \
	&& rm -f /usr/local/etc/php/conf.d/docker-php-ext-apc.ini \
	&& rm -f /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini \
	&& rm -f /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
	&& mkdir -p /etc/php7.d/conf.d /etc/php7-fpm.d \
	&& cp /usr/local/etc/php/conf.d/* /etc/php7.d/conf.d/ \
	&& cp /usr/local/etc/php-fpm.d/* /etc/php7-fpm.d/ \
	&& :

COPY files/*.ini /usr/local/etc/php/conf.d/
COPY files/opcache*.blacklist /etc/php7.d/
COPY files/www.conf /etc/php7-fpm.d/
COPY files/php7-fpm.conf /etc/

#sed -i -E "s;^extension_dir\s*=.*$;extension_dir = \"${EXTENSIONDIR}\";" %{SOURCE3}
#cp %{SOURCE3} $RPM_BUILD_ROOT/etc/php7.d/php.ini
#
#COPY %{SOURCE5} $RPM_BUILD_ROOT/etc/php7-fpm.d/php7-fpm.conf.kusanagi
#COPY %{SOURCE6} $RPM_BUILD_ROOT/etc/php7-fpm.d/www.conf.kusanagi
#
#COPY $RPM_BUILD_ROOT/etc/php7-fpm.d/www.conf.kusanagi $RPM_BUILD_ROOT/etc/php7-fpm.d/www.conf
#COPY $RPM_BUILD_ROOT/etc/php7-fpm.d/php7-fpm.conf.kusanagi $RPM_BUILD_ROOT/etc/php7-fpm.conf
#echo "d /run/php7-fpm 0755 root root" > $RPM_BUILD_ROOT/etc/tmpfiles.d/php7-fpm.conf




ARG MICROSCANER_TOKEN
RUN if [ x${MICROSCANER_TOKEN} != x ] ; then \
	apk add --no-cache --virtual .ca ca-certificates \
	&& update-ca-certificates\
	&& wget --no-check-certificate https://get.aquasec.com/microscanner \
	&& chmod +x microscanner \
	&& ./microscanner ${MICROSCANER_TOKEN} || exit 1\
	&& rm ./microscanner \
	&& apk del --purge --virtual .ca ;\
    fi

USER httpd
#CMD ["/usr/local/bin/php" "--nodaemonize" "--fpm-config" "/etc/php7-fpm.conf"]
