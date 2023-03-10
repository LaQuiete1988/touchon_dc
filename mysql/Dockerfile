FROM alpine:3.16

ENV TZ=Europe/Moscow

RUN apk update && apk add --no-cache mysql mysql-client tzdata \
 && mkdir /var/backup/ \
 && crontab -r \
 && crontab -l | \
 { cat; echo "00 01 * * * cd / && ./backup.sh >> /var/log/cron.log 2>&1"; } | crontab -

COPY docker-entrypoint.sh backup.sh /
COPY my.cnf /etc/mysql/my.cnf

RUN chmod +x docker-entrypoint.sh backup.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
