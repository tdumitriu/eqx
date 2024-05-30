#!/bin/bash

# shellcheck disable=SC2046
source $(pwd)/scripts/env.sh

echo "Building [${IMAGE_PREFIX}/${IMAGE_NAME}:${IMAGE_VERSION}] image ..."
docker build -t "${IMAGE_PREFIX}"/"${IMAGE_NAME}":"${IMAGE_VERSION}" .

echo "Image [${IMAGE_PREFIX}/${IMAGE_NAME}:${IMAGE_VERSION}] has been built"
