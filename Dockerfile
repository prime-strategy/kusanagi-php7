#//----------------------------------------------------------------------------
#// PHP7 FastCGI Server ( for KUSANAGI Runs on Docker )
#//----------------------------------------------------------------------------
FROM php:7.3.5-fpm-alpine3.9
MAINTAINER kusanagi@prime-strategy.co.jp

# Environment variable
ARG APCU_VERSION=5.1.17
ARG APCU_BC_VERSION=1.0.5
ARG MOZJPEG_VERSION=3.3.1

# add user
RUN : \
	&& apk update \
	&& apk upgrade \
	&& apk add --virtual .user shadow \
	&& groupadd -g 1001 www \
	&& useradd -d /var/lib/www -s /bin/nologin -g www -M -u 1001 httpd \
        && groupadd -g 1000 kusanagi \
        && useradd -d /home/kusanagi -s /bin/nologin -g kusanagi -G www -u 1000 -m kusanagi \
        && chmod 755 /home/kusanagi \
	&& apk del --purge .user \
	&& chown -R httpd:www /var/www/html \
	&& :

COPY files/add_dev.sh /usr/local/bin
COPY files/del_dev.sh /usr/local/bin

RUN /usr/local/bin/add_dev.sh \
	&& cd /tmp \
\
# mozjpeg
\
	&& curl -LO https://github.com/mozilla/mozjpeg/archive/v${MOZJPEG_VERSION}.tar.gz#//mozjpeg-${MOZJPEG_VERSION}.tar.gz \
	&& tar xf mozjpeg-${MOZJPEG_VERSION}.tar.gz \
	&& cd mozjpeg-${MOZJPEG_VERSION} \
	&& autoreconf -fiv \
	&& mkdir build && cd build \
	&& sh ../configure --with-jpeg8 --prefix=/usr \
	&& make -j$(getconf _NPROCESSORS_ONLN) install \
\
# PHP7.3
\
	&& pecl channel-update pecl.php.net \
	&& docker-php-ext-configure gd --with-jpeg-dir=/usr/include \
		--with-xpm-dir=/usr/include --with-webp-dir=/usr/include \
		--with-png-dir=/usr/include --with-freetype-dir=/usr/include/ \
	&& docker-php-ext-install \
		mysqli \
		pgsql \
		opcache \
		gd \
		calendar \
		imap \
		ldap \
		bz2 \
		zip \
		pdo \
		pdo_mysql \
		pdo_pgsql \
		bcmath \
		exif \
		gettext \
		pcntl \
		soap \
		sockets \
		sysvsem \
		sysvshm \
		xmlrpc \
		xsl \
	&& pecl install imagick \
	&& pecl install libsodium \
	&& pecl install apcu-$APCU_VERSION \
	&& pecl install apcu_bc-$APCU_BC_VERSION \
	&& docker-php-ext-enable imagick apcu apc \
	&& /usr/local/bin/del_dev.sh \
	&& cd / \
	&& rm -f /usr/local/etc/php/conf.d/docker-php-ext-apc.ini \
	&& rm -f /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini \
	&& rm -f /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
	&& rm -rf /tmp/mozjpeg* /tmp/pear /usr/include /usr/lib/pkgconfig /usr/lib/*a /usr/share/doc /usr/share/man \
	&& apk add pngquant optipng jpegoptim ssmtp \
	&& chown httpd /etc/ssmtp /etc/ssmtp/ssmtp.conf \
	&& mkdir -p /etc/php7.d/conf.d /etc/php7-fpm.d \
	&& cp /usr/local/etc/php/conf.d/* /etc/php7.d/conf.d/ \
	&& cp /usr/local/etc/php-fpm.d/* /etc/php7-fpm.d/ \
	&& mkdir -p /var/log/php7-fpm \
	&& ln -sf /dev/stdout /var/log/php7-fpm/www-error.log \
	&& ln -sf /dev/stderr /var/log/php7-fpm/www-slow.log \
	&& :

RUN	mkdir -p /var/lib/php7/session /var/lib/php7/wsdlcache  \
	&& chown httpd:www /var/lib/php7/session /var/lib/php7/wsdlcache \
	&& echo mysqli.default_socket=/var/run/mysqld/mysqld.sock >> /usr/local/etc/php/conf.d/docker-php-ext-mysqli.ini \
	&& echo pdo_mysql.default_socket = /var/run/mysqld/mysqld.sock >> /usr/local/etc/php/conf.d/docker-php-ext-pdo_mysql.ini \
	&& cd /tmp \
	&& curl -LO https://composer.github.io/installer.sha384sum \
	&& curl -LO https://getcomposer.org/installer \
	&& sha3sum installer.sha384sum \
	&& php installer --filename=composer --install-dir=/usr/local/bin \
	&& rm installer \
	&& :

COPY files/*.ini /usr/local/etc/php/conf.d/
COPY files/opcache*.blacklist /usr/local/etc/php.d/
COPY files/www.conf /usr/local/etc/php-fpm.d/www.conf.template
COPY files/php7-fpm.conf /usr/local/etc/php-fpm.conf
COPY files/php.ini-production /usr/local/etc/php.conf
COPY files/docker-entrypoint.sh /usr/local/bin
RUN chown -R httpd:www /usr/local/etc

ARG MICROSCANNER_TOKEN
RUN if [ x${MICROSCANNER_TOKEN} != x ] ; then \
	apk add --no-cache --virtual .ca ca-certificates \
	&& update-ca-certificates\
	&& wget --no-check-certificate https://get.aquasec.com/microscanner \
	&& chmod +x microscanner \
	&& ./microscanner ${MICROSCANNER_TOKEN} || exit 1\
	&& rm ./microscanner \
	&& apk del --purge --virtual .ca ;\
    fi

USER httpd
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/local/sbin/php-fpm", "--nodaemonize", "--fpm-config", "/usr/local/etc/php-fpm.conf"]
