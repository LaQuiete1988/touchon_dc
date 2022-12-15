FROM alpine:3.16

ENV TZ=Europe/Moscow

RUN apk update && apk add --no-cache mysql mysql-client tzdata \
 && mkdir /var/backup/ \
 && crontab -r \
 && crontab -l | \
 { cat; echo "20 0 * * * mysqldump -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} \
| gzip > /var/backup/db_backup.$(date +"%d.%m.%Y").sql.gz >> /var/log/cron.log 2>&1"; } | crontab - \
 && touch /var/log/cron.log

COPY docker-entrypoint.sh /
COPY my.cnf /etc/mysql/my.cnf

RUN chmod +x /docker-entrypoint.sh /backup.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
