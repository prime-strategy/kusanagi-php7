#!/bin/sh

#//---------------------------------------------------------------------------
#// generate www configuration file
#//---------------------------------------------------------------------------
(cd /usr/local/etc/php-fpm.d \
&& env \
    PHP_PORT=${PHP_PORT:-9000} \
    PHP_MAX_CHILDLEN=${PHP_MAX_CHILDLEN:-50} \
    PHP_START_SERVERS=${PHP_START_SERVERS:-10} \
    PHP_MIN_SPARE_SERVERS=${PHP_MIN_SPARE_SERVERS:-5} \
    PHP_MAX_SPARE_SERVERS=${PHP_MAX_SPARE_SERVERS:-15} \
    PHP_MAX_REQUESTS=${PHP_MAX_REQUESTS:-500} \
    /usr/bin/envsubst '$$PHP_PORT $$PHP_MAX_CHILDLEN $$PHP_START_SERVERS
	$$PHP_MIN_SPARE_SERVERS $$PHP_MAX_SPARE_SERVERS $$PHP_MAX_REQUESTS' \
	< www.conf.template > www.conf) \
|| exit 1

#//---------------------------------------------------------------------------
#// execute nginx
#//---------------------------------------------------------------------------
exec "$@"
