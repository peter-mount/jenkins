#!/bin/sh

CPU=
case $(uname -m) in
  x86_64)
    CPU=x86_64
    ;;
  armv7l)
    CPU=armhf
    ;;
  aarch64)
    CPU=aarch64
    ;;
esac
echo https://download.docker.com/linux/static/stable/$CPU/docker-19.03.12.tgz
