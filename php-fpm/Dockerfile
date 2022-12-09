FROM php:7.4-fpm-alpine3.16

ENV TZ=Europe/Moscow

WORKDIR /var/www

RUN apk update \
 && apk add --no-cache git tzdata \
 && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing git-extras \
 && docker-php-ext-install bcmath mysqli pdo_mysql pcntl \
 && crontab -l | { cat; echo "*/1 * * * * cd /var/www/server && php watchdog.php >> /var/log/cron.log 2>&1"; } | crontab - \
 && crontab -l | { cat; echo "*/1 * * * * cd /var/www/server && php cron.php 1 >> /var/log/cron.log 2>&1"; } | crontab - \
 && crontab -l | { cat; echo "*/5 * * * * cd /var/www/server && php cron.php 5 >> /var/log/cron.log 2>&1"; } | crontab - \
 && crontab -l | { cat; echo "*/60 * * * * cd /var/www/server && php cron.php 60 >> /var/log/cron.log 2>&1"; } | crontab - \
 && crontab -l | { cat; echo "*/1 * * * * cd /var/www/server && php main.php >> /var/log/cron.log 2>&1"; } | crontab - \
 && touch /var/log/cron.log \
 && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
 && sed -i 's/;date.timezone =/date.timezone = Europe\/Moscow/' /usr/local/etc/php/php.ini

#COPY ./apps /var/www/adm

CMD bash -c "crond && php-fpm"
