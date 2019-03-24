FROM alpine:latest
RUN apk update && apk add curl busybox-extras
ENTRYPOINT ["tail","-f","/dev/null"]

