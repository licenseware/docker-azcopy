ARG AZCOPY_VERSION=v10.23.0
ARG GO_VERSION=1.22
ARG ALPINE_VERSION=3.19
ARG TARGETARCH

FROM golang:$GO_VERSION-alpine$ALPINE_VERSION as build
ENV GOARCH=$TARGETARCH GOOS=linux CGO_ENABLED=0
WORKDIR /azcopy
ARG AZCOPY_VERSION
RUN apk add --no-cache build-base
RUN wget "https://github.com/Azure/azure-storage-azcopy/archive/$AZCOPY_VERSION.tar.gz" -O src.tgz
RUN tar xf src.tgz --strip 1 \
  && go build -o azcopy \
  && ./azcopy --version

FROM curlimages/curl AS entrypoint

ARG DUMB_INIT="https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64"

USER root
RUN curl -L -o /usr/local/bin/dumb-init $DUMB_INIT && \
  chmod +x /usr/local/bin/dumb-init

FROM alpine:$ALPINE_VERSION as release

ARG AZCOPY_VERSION
LABEL name="docker-azcopy"
LABEL version="$AZCOPY_VERSION"
LABEL maintainer="Meysam <meysam@licenseware.io>"

COPY --from=entrypoint /usr/local/bin/dumb-init /usr/local/bin/dumb-init
COPY --from=build /azcopy/azcopy /usr/local/bin/

ENTRYPOINT [ "dumb-init", "--", "azcopy" ]
CMD [ "--help" ]
