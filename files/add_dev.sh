#!
apk update \
&& apk add --update --no-cache --virtual .build-php \
		$PHPIZE_DEPS \
		build-base \
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
		imagemagick \
		imagemagick-dev \
		libsodium \
		libsodium-dev \
		gettext \
	&& :

