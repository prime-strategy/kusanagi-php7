#//----------------------------------------------------------------------------
#// PHP7 FastCGI Server ( for KUSANAGI Runs on Docker )
#//----------------------------------------------------------------------------
FROM php:7.3.0-fpm-alpine3.8
MAINTAINER kusanagi@prime-strategy.co.jp

# Environment variable
ARG APCU_VERSION=5.1.13
ARG APCU_BC_VERSION=1.0.4
ARG MOZJPEG_VERSION=3.3.1

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
		automake \
		gettext \
		libtool \
		nasm \
		mariadb \
		mariadb-dev \
		postgresql \
		postgresql-dev \
		gd-dev \
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
		curl \
	&& cd /tmp \
	&& curl -LO https://github.com/mozilla/mozjpeg/archive/v${MOZJPEG_VERSION}.tar.gz#//mozjpeg-${MOZJPEG_VERSION}.tar.gz \
	&& tar xf mozjpeg-${MOZJPEG_VERSION}.tar.gz \
	&& cd mozjpeg-${MOZJPEG_VERSION} \
	&& autoreconf -fiv \
	&& mkdir build && cd build \
	&& sh ../configure --with-jpeg8 --prefix=/usr \
	&& make -j$(getconf _NPROCESSORS_ONLN) install \
	&& strip \
		/usr/bin/wrjpgcom \
		/usr/bin/rdjpgcom \
		/usr/bin/cjpeg \
		/usr/bin/jpegtran \
		/usr/bin/djpeg \
		/usr/bin/tjbench \
		/usr/lib/libturbojpeg.so.0.1.0 \
		/usr/lib/libjpeg.so.8.1.2 \
	&& cp /usr/lib/libturbojpeg.so.0.1.0 \
		/usr/lib/libjpeg.so.8.1.2 \
		/tmp \
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
			| grep -v jpeg \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apk add --no-cache --virtual .php7-rundeps $runDeps \
	&& apk del .build-php \
	&& cd / \
	&& rm -f /usr/local/etc/php/conf.d/docker-php-ext-apc.ini \
	&& rm -f /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini \
	&& rm -f /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
	&& rm -rf /tmp/mozjpeg* /usr/include /usr/lib/pkgconfig /usr/lib/*a /usr/share/doc /usr/share/man \
\
#	&& apk add pngquant optipng imagemagick\
\
	&& apk add pngquant optipng jpegoptim \
	&& mv /tmp/libturbojpeg.so.0.1.0 /tmp/libjpeg.so.8.1.2 /usr/lib \
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
