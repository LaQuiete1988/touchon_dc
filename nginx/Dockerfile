FROM nginx:1.23.2-alpine

ENV TZ=Europe/Moscow

RUN apk --update add --no-cache tzdata

CMD ["nginx", "-g", "daemon off;"]
