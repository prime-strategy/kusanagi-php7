#!/bin/sh

#//---------------------------------------------------------------------------
#// generate www configuration file
#//---------------------------------------------------------------------------
(cd /usr/local/etc/php-fpm.d \
&& env \
    PHP_PORT=${PHP_PORT:-127.0.0.1:9000} \
    PHP_ALLOWED=${PHP_ALLOWED:-127.0.0.1} \
    PHP_MAX_CHILDLEN=${PHP_MAX_CHILDLEN:-50} \
    PHP_START_SERVERS=${PHP_START_SERVERS:-10} \
    PHP_MIN_SPARE_SERVERS=${PHP_MIN_SPARE_SERVERS:-5} \
    PHP_MAX_SPARE_SERVERS=${PHP_MAX_SPARE_SERVERS:-15} \
    PHP_MAX_REQUESTS=${PHP_MAX_REQUESTS:-500} \
    /usr/bin/envsubst '$$PHP_PORT $$PHP_ALLOWED $$PHP_MAX_CHILDLEN $$PHP_START_SERVERS
	$$PHP_MIN_SPARE_SERVERS $$PHP_MAX_SPARE_SERVERS $$PHP_MAX_REQUESTS' \
	< www.conf.template > www.conf) \
|| exit 1

#//---------------------------------------------------------------------------
#// generate ssmtp configuration file
#//---------------------------------------------------------------------------
[ "x$MAILSERVER" != "x" ] && \
	sed -i 's/mailhub=.*$/mailhub=$MAILSERVER/' /etc/ssmtp/ssmtp.conf ;
[ "x$MAILDOMAIN" != "x" ] && \
	echo "rewriteDomain=$MAILDOMAIN" >> /etc/ssmtp/ssmtp.conf
[ "x$MAILUSER" != "x" -a "x$MAILPASS" != "x" ] && \
	(echo "AuthUser=$MAILUSER";echo "AuthPass=$MAILPASS") >> /etc/ssmtp/ssmtp.conf \
	&& [ "x$MAILAUTH" != "x" ] && \
	echo "AuthMethod=$MAILAUTH" >> /etc/ssmtp/ssmtp.conf

#//---------------------------------------------------------------------------
#// execute nginx
#//---------------------------------------------------------------------------
exec "$@"
