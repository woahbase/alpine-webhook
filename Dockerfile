# syntax=docker/dockerfile:1
#
ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
ARG SRCARCH
ARG VERSION
#
RUN set -xe \
    && apk add --no-cache --purge -uU \
        curl \
        gcompat \
    && echo "Using version: $VERSION" \
    && curl -o /tmp/webhook-${SRCARCH}.tar.gz -SL https://github.com/adnanh/webhook/releases/download/${VERSION}/webhook-${SRCARCH}.tar.gz \
    && tar zxf /tmp/webhook-${SRCARCH}.tar.gz -C /usr/local/bin --strip 1 \
    # && ln -s /usr/local/webhook-${SRCARCH}/webhook /usr/local/bin \
    # && chown -R alpine:alpine /usr/local/webhook-${SRCARCH}/ \
    # && chown -R alpine:alpine /usr/local/bin/webhook \
    && rm -rf /var/cache/apk/* /tmp/*
#
COPY root/ /
#
VOLUME /etc/webhook/
#
EXPOSE 9000
#
HEALTHCHECK \
    --interval=2m \
    --retries=5 \
    --start-period=5m \
    --timeout=10s \
    CMD \
    wget --quiet --tries=1 --no-check-certificate --spider ${HEALTHCHECK_URL:-"http://localhost:9000/hooks/version"} || exit 1
#
ENTRYPOINT ["/init"]
