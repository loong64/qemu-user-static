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
    && apt-get download qemu-user qemu-user-static

COPY docker-entrypoint.sh /opt/

RUN set -ex \
    && wget https://github.com/multiarch/qemu-user-static/raw/master/containers/latest/register.sh \
    && wget https://github.com/qemu/qemu/raw/master/scripts/qemu-binfmt-conf.sh \
    && chmod +x *.sh

FROM debian:trixie-slim

COPY --from=builder /opt/qemu*.deb /opt/
COPY --from=builder /opt/*.sh /

ENV QEMU_BIN_DIR=/usr/bin

ENTRYPOINT ["/docker-entrypoint.sh"]