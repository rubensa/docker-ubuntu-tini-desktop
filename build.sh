#!/usr/bin/env bash

DOCKER_REPOSITORY_NAME="rubensa"
DOCKER_IMAGE_NAME="ubuntu-tini-desktop"
DOCKER_IMAGE_TAG="latest"

# Get current user name
NEW_USER_NAME=$(id -un)
# Get current user main group name
NEW_GROUP_NAME=$(id -gn)

prepare_docker_user_and_group() {
  # On build, if you specify NEW_USER_NAME or NEW_GROUP_NAME those are used to define the
  # internal user and group created instead of default ones (user and group)
  BUILD_ARGS+=" --build-arg NEW_USER_NAME=$NEW_USER_NAME"
  BUILD_ARGS+=" --build-arg NEW_GROUP_NAME=$NEW_GROUP_NAME"
}

prepare_docker_user_and_group

docker build --no-cache \
  -t "${DOCKER_REPOSITORY_NAME}/custom-${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}" \
  --label "maintainer=Ruben Suarez <rubensa@gmail.com>" \
  ${BUILD_ARGS} \
  .
