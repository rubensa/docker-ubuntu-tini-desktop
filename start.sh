#!/usr/bin/env bash

DOCKER_IMAGE_NAME="ubuntu-tini-desktop"

# IMPORTANT! You MUST run this command before starting the container to update the link
if [ -f "${XAUTHORITY}" ] && [ "${XAUTHORITY}" != "${HOME}/.Xauthority" ]; then ln -sf "${XAUTHORITY}" "${HOME}/.Xauthority"; fi;

docker start \
  "${DOCKER_IMAGE_NAME}"
