ARG ALPINE_IMAGE_TAG=3.22

FROM docker.io/alpine:$ALPINE_IMAGE_TAG as builder

ARG LITESTREAM_VERSION=v0.3.13

# Fetch and extract litestream
ADD https://github.com/benbjohnson/litestream/releases/download/$LITESTREAM_VERSION/litestream-$LITESTREAM_VERSION-linux-amd64.tar.gz /tmp/litestream.tar.gz
RUN tar -C /usr/local/bin -xzf /tmp/litestream.tar.gz

# Pull goatcounter image
FROM alpine:$ALPINE_IMAGE_TAG

ARG GOATCOUNTER_VERSION=v2.6.0

# Copy Litestream from builder.
COPY --from=builder /usr/local/bin/litestream /usr/local/bin/litestream

# Copy Litestream configuration file.
COPY etc/litestream.yml /etc/litestream.yml

WORKDIR /goatcounter

# Fetch goatcounter
ADD https://github.com/arp242/goatcounter/releases/download/$GOATCOUNTER_VERSION/goatcounter-$GOATCOUNTER_VERSION-linux-amd64.gz /tmp/goatcounter.gz

# Install dependencies, extract & install goatcounter
RUN apk add --no-cache ca-certificates bash sqlite \
    && update-ca-certificates --fresh \
    && gzip -d "/tmp/goatcounter.gz" \
    && mv "/tmp/goatcounter" /usr/local/bin/goatcounter \
    && chmod +x /usr/local/bin/goatcounter

COPY goatcounter.sh ./
COPY entrypoint.sh /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/goatcounter/goatcounter.sh"]
