FROM php:7.4-fpm-alpine3.16

ENV TZ=Europe/Moscow

WORKDIR /var/www

RUN apk update \
 && apk add --no-cache git tzdata lftp wget \
 && docker-php-ext-install bcmath mysqli pdo_mysql pcntl \
 && crontab -r \
 && crontab -l | { cat; echo "*/1 * * * * cd /var/www/server && php watchdog.php"; } | crontab - \
 && crontab -l | { cat; echo "*/1 * * * * cd /var/www/server && php cron.php 1"; } | crontab - \
 && crontab -l | { cat; echo "*/5 * * * * cd /var/www/server && php cron.php 5"; } | crontab - \
 && crontab -l | { cat; echo "*/60 * * * * cd /var/www/server && php cron.php 60"; } | crontab - \
 && crontab -l | { cat; echo "*/1 * * * * cd /var/www/server && php main.php"; } | crontab - \
#  && touch /var/log/cron.log \
 && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
 && sed -i 's/;date.timezone =/date.timezone = Europe\/Moscow/' /usr/local/etc/php/php.ini

CMD /bin/sh -c "crond && php-fpm"
