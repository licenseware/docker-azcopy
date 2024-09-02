ARG AZCOPY_VERSION=v10.26.0
ARG GO_VERSION=1.23
ARG ALPINE_VERSION=3.20
ARG TARGETARCH

FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} as build

ARG TARGETARCH
ARG AZCOPY_VERSION

ENV GOARCH=$TARGETARCH GOOS=linux CGO_ENABLED=0

WORKDIR /azcopy

RUN apk add --no-cache build-base && \
    wget -O azcopy.tar.gz https://github.com/Azure/azure-storage-azcopy/archive/${AZCOPY_VERSION}.tar.gz && \
    tar -xzf azcopy.tar.gz --strip-components=1 && \
    go build -o azcopy && \
    ./azcopy --version

FROM busybox AS entrypoint-amd64

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64 /usr/local/bin/dumb-init

RUN chmod +x /usr/local/bin/dumb-init

FROM busybox AS entrypoint-arm64

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_aarch64 /usr/local/bin/dumb-init

RUN chmod +x /usr/local/bin/dumb-init

FROM alpine:${ALPINE_VERSION} as release

ARG TARGETARCH
ARG AZCOPY_VERSION

LABEL name="docker-azcopy"
LABEL version="$AZCOPY_VERSION"
LABEL maintainer="Meysam <meysam@licenseware.io>"

COPY --from=entrypoint-amd64 /usr/local/bin/dumb-init /usr/local/bin/dumb-init-amd64
COPY --from=entrypoint-arm64 /usr/local/bin/dumb-init /usr/local/bin/dumb-init-arm64

COPY --from=build /azcopy/azcopy /usr/local/bin/

RUN if [ "$TARGETARCH" = "amd64" ]; then \
        mv /usr/local/bin/dumb-init-amd64 /usr/local/bin/dumb-init; \
    else \
        mv /usr/local/bin/dumb-init-arm64 /usr/local/bin/dumb-init; \
    fi && \
    apk add --update coreutils && \
    rm -rf /var/cache/apk/*

ENTRYPOINT [ "dumb-init", "--" ]
CMD [ "azcopy", "--help" ]
