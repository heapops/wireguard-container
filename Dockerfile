FROM alpine:edge
LABEL maintainer="heapops <heapops@gmail.com>"

RUN apk --no-cache add wireguard-tools

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh", "/entrypoint.sh"]
