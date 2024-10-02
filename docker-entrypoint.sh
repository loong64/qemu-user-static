#!/bin/sh

dpkg --unpack /opt/qemu*.deb

exec /register.sh "$@"