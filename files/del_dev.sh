#!
mv /usr/bin/envsubst /tmp/ \
&& runPath="/usr/local/bin/php
 /usr/local/lib/php/extensions/no-debug-non-zts-20180731/*.so
 /tmp/envsubst
 /usr/bin/mogrify 
 /usr/bin/wrjpgcom
 /usr/bin/rdjpgcom
 /usr/bin/cjpeg
 /usr/bin/jpegtran
 /usr/bin/djpeg
 /usr/bin/tjbench
 /usr/lib/libturbojpeg.so.0.1.0
 /usr/lib/libjpeg.so.8.1.2" \
&& runDeps="$( \
	scanelf --needed --nobanner --format '%n#p' $runPath \
	| tr ',' '\n' \
	| sort -u \
	| grep -v jpeg \
	| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
&& strip $runPath \
&& apk add --no-cache --virtual .php7-rundeps $runDeps \
&& apk del .build-php \
&& mv /tmp/envsubst /usr/bin/envsubst \
&& :

