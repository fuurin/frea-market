FROM ruby:2.6-alpine

ARG WORKDIR

ENV RUNTIME_PACKAGES="linux-headers libxml2-dev make gcc libc-dev nodejs less tzdata mysql-client mysql-dev openssl git" \
    DEV_PACKAGES="build-base curl-dev vim less" \
    HOME=/${WORKDIR} \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo \
    EDITOR=vi

WORKDIR ${HOME}

COPY Gemfile* ./

RUN apk update && \
    apk upgrade && \
    apk add --no-cache ${RUNTIME_PACKAGES} && \
    apk add --virtual build-dependencies --no-cache ${DEV_PACKAGES} && \
    bundle config --local build.mysql2 "--with-ldflags=-L/usr/local/bin/openssl/lib" && \
    bundle install -j4 && \
    apk del build-dependencies

COPY . .
