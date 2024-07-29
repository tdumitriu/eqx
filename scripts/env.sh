#!/bin/bash

# Image build
# shellcheck disable=SC2034
EQX_HOME="."
IMAGE_PREFIX="tdumitriu"
IMAGE_NAME="eqx"
IMAGE_PATH="images"
IMAGE_VERSION="1.0.0"
EC2_INSTANCE_IP="44.206.245.119"
EC2_USERNAME="ubuntu"
REMOTE_PATH="images"
REMOTE_HOME="/home/ubuntu"
DOCKERFILE_PATH="."
CONTAINER_NAME="eqx"
HOME_BUILD=build
LOCAL_BUILD_DIST="./${HOME_BUILD}/distributions/eqx-0.1.tar"
REMOTE_BUILD_DIST_PATH="eqx/build/distributions"
REMOTE_BUILD_DIST_TAR="${REMOTE_BUILD_DIST_PATH}/eqx-0.1.tar"
LOCAL_DOCKERFILE="./Dockerfile"
REMOTE_DOCKERFILE="eqx/Dockerfile"

# Environment
# Local
HOSTNAME=localhost
PORT=8383

# Remote
REMOTE_HOSTNAME=localhost
INTERNAL_PORT=8383
REMOTE_PORT=8383
