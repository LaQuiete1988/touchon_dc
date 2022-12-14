FROM alpine:3.16

ENV TZ=Europe/Moscow

RUN apk update && apk add --no-cache rsync tzdata \
 && mkdir /var/backup/ \
 && crontab -r \
 && crontab -l | \
 { cat; echo "30 9 * * * /backup.sh >> /var/log/cron.log 2>&1"; } | crontab - \
 && touch /var/log/cron.log

WORKDIR /var/backup

RUN ["crond"]