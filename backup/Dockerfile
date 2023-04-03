FROM alpine:3.16

ENV TZ=Europe/Moscow

COPY backup.sh /

RUN apk update && apk add --no-cache rsync tzdata openssh-client tar sshpass mysql-client \
 && mkdir /var/backup/ \
 && crontab -r \
 && crontab -l | { cat; echo "00 01 * * * \
cd / && ./backup.sh \
>> /var/log/cron.log 2>&1"; } | crontab - \
 && touch /var/log/cron.log \
 && chmod +x /backup.sh

CMD /bin/sh -c "crond && tail -f /var/log/cron.log"
