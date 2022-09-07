#!/usr/bin/env bash

DOCKER_IMAGE_NAME="ubuntu-tini-desktop"

docker stop  \
  "${DOCKER_IMAGE_NAME}"
