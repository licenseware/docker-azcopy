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

FROM alpine:${ALPINE_VERSION} as release

ARG TARGETARCH
ARG AZCOPY_VERSION

LABEL name="docker-azcopy"
LABEL version="$AZCOPY_VERSION"
LABEL maintainer="Meysam <meysam@licenseware.io>"

COPY --from=entrypoint-amd64 /usr/local/bin/dumb-init /usr/local/bin/dumb-init-amd64
COPY --from=entrypoint-arm64 /usr/local/bin/dumb-init /usr/local/bin/dumb-init-arm64

COPY --from=build /azcopy/azcopy /usr/local/bin/

RUN apk add --update coreutils && \
    rm -rf /var/cache/apk/*

CMD [ "azcopy", "--help" ]
