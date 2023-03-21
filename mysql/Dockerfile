FROM alpine:3.16

ENV TZ=Europe/Moscow

COPY docker-entrypoint.sh /
COPY my.cnf /etc/mysql/my.cnf

RUN apk update && apk add --no-cache mysql mysql-client tzdata \
    && chmod +x docker-entrypoint.sh 

ENTRYPOINT ["/docker-entrypoint.sh"]
