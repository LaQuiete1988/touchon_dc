FROM alpine:3.16

ENV TZ=Europe/Moscow

RUN apk update && apk add --no-cache mysql mysql-client tzdata

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY my.cnf /etc/mysql/my.cnf

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
