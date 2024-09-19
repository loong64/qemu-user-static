FROM debian:trixie-slim AS builder

ARG DEPENDENCIES="      \
        ca-certificates \
        wget"

WORKDIR /opt

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -ex \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES} \
    && apt-get download qemu-user-static

RUN set -ex \
    && wget https://github.com/multiarch/qemu-user-static/raw/master/containers/latest/register.sh \
    && wget https://github.com/qemu/qemu/raw/master/scripts/qemu-binfmt-conf.sh \
    && chmod +x register.sh qemu-binfmt-conf.sh

FROM debian:trixie-slim

RUN --mount=type=bind,from=builder,source=/opt,target=/opt \
    set -ex \
    && cd /opt \
    && cp -f /opt/register.sh /register \
    && cp -f /opt/qemu-binfmt-conf.sh /qemu-binfmt-conf.sh \
    && dpkg --unpack qemu*.deb

ENV QEMU_BIN_DIR=/usr/bin

ENTRYPOINT ["/register"]