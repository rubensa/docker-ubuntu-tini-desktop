#!/usr/bin/env bash

DOCKER_IMAGE_NAME="ubuntu-tini-desktop"

docker rm \
  "${DOCKER_IMAGE_NAME}"
