FROM alpine:3.16

ENV TZ=Europe/Moscow

COPY backup.sh /

RUN apk update && apk add --no-cache rsync tzdata openssh-client tar \
 && mkdir /var/backup/ \
 && crontab -r \
 && crontab -l | { cat; echo "00 02 * * * \
cd / && ./backup.sh \
>> /var/log/cron.log 2>&1"; } | crontab - \
#  && crontab -l | { cat; echo "0 1 * * 1 \
# rsync -arvt /var/www/server/userscripts/. /var/backup/userscripts.\$(date +\"%d.%m.%Y\") \
# >> /var/log/cron.log 2>&1"; } | crontab - \
#  && crontab -l | { cat; echo "30 3 * * 1 \
# find /var/backup -type f -mtime +7 -exec rm -f {} \; \
# >> /var/log/cron.log 2>&1"; } | crontab - \
#  && crontab -l | { cat; echo "0 5 * * 1 /backup.sh >> /var/log/cron.log 2>&1"; } | crontab - \
 && touch /var/log/cron.log \
# && crontab -l | { cat; echo "*/1 * * * * echo hello >> /var/log/cron.log 2>&1"; } | crontab - \
 && chmod +x /backup.sh

#RUN ["crond"]
#CMD tail -f /var/log/cron.log
CMD /bin/sh -c "crond && tail -f /var/log/cron.log"
