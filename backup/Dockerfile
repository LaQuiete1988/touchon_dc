FROM alpine:3.16

ENV TZ=Europe/Moscow

COPY backup.sh /

RUN apk update && apk add --no-cache rsync tzdata \
 && mkdir /var/backup/ \
 && crontab -r \
 && crontab -l | { cat; echo "10 0 * * * \
rsync -azq --delete /var/www/server/userscripts/. /var/backup/userscripts.dayly \
>> /var/log/cron.log 2>&1"; } | crontab - \
 && crontab -l | { cat; echo "0 1 * * 1 \
rsync -arvt /var/www/server/userscripts/. /var/backup/userscripts.`date + "%d.%m.%Y"` \
>> /var/log/cron.log 2>&1"; } | crontab - \
 && crontab -l | { cat; echo "30 3 * * 1 \
find /var/backup -type f -mtime +7 -exec rm -f {} \; \
>> /var/log/cron.log 2>&1"; } | crontab - \
 && crontab -l | { cat; echo "0 5 * * 1 /backup.sh >> /var/log/cron.log 2>&1"; } | crontab - \
 && touch /var/log/cron.log \
 && chmod +x /backup.sh



RUN ["crond"]