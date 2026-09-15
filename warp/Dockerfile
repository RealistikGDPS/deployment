# usque, a userspace Cloudflare WARP client, run as a plain HTTP proxy. Built
# from a tagged source checkout because upstream publishes no image.
FROM golang:1.26-alpine AS builder

ARG USQUE_VERSION=v4.2.1

RUN apk add --no-cache git
RUN git clone --depth 1 --branch "${USQUE_VERSION}" https://github.com/Diniboy1123/usque /src
WORKDIR /src
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /usque .

FROM alpine:3.22

RUN apk add --no-cache ca-certificates
COPY --from=builder /usque /usr/local/bin/usque

ENTRYPOINT ["/usr/local/bin/usque"]
