ARG AZCOPY_VERSION=v10.26.0
ARG GO_VERSION=1.23
ARG ALPINE_VERSION=3.20

FROM curlimages/curl AS entrypoint

ARG DUMB_INIT_AMD='https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64'
ARG DUMB_INIT_ARM='https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_aarch64'

ARG TARGETARCH

USER root

RUN if [ "${TARGETARCH}" = "amd64" ]; then \
        curl -sSfLo /usr/local/bin/dumb-init ${DUMB_INIT_AMD} && \
        chmod +x /usr/local/bin/dumb-init; \
    elif [ "${TARGETARCH}" = "arm64" ]; then \
        curl -sSfLo /usr/local/bin/dumb-init ${DUMB_INIT_ARM} && \
        chmod +x /usr/local/bin/dumb-init; \
    else \
        echo "Unsupported architecture: $TARGETARCH"; \
        exit 1; \
    fi

FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS build

ARG AZCOPY_VERSION
ARG TARGETARCH

ENV GOARCH=$TARGETARCH GOOS=linux CGO_ENABLED=0

WORKDIR /azcopy

RUN apk add --no-cache build-base && \
    wget -O azcopy.tar.gz https://github.com/Azure/azure-storage-azcopy/archive/${AZCOPY_VERSION}.tar.gz && \
    tar -xzf azcopy.tar.gz --strip-components=1 && \
    go build -o azcopy && \
    ./azcopy --version


FROM busybox:1 AS release

LABEL maintainer="Meysam <meysam@licenseware.io>"

COPY --from=entrypoint /usr/local/bin/dumb-init /usr/local/bin/dumb-init
COPY --from=build /azcopy/azcopy /usr/local/bin/

RUN apk add --update coreutils && \
    rm -rf /var/cache/apk/*

ENTRYPOINT [ "dumb-init", "--" ]
CMD [ "azcopy --help" ]
