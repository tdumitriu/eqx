#!/bin/bash

# shellcheck disable=SC2046
source $(pwd)/scripts/env.sh

echo "Compressing and saving image [${IMAGE_NAME}:${IMAGE_VERSION}] to ${EQX_HOME}/${IMAGE_PATH} folder ..."
docker save --output "${EQX_HOME}"/"${IMAGE_PATH}"/"${IMAGE_NAME}"_"${IMAGE_VERSION}".tar \
       "${IMAGE_PREFIX}"/"${IMAGE_NAME}":"${IMAGE_VERSION}"

echo "Image [${IMAGE_NAME}:${IMAGE_VERSION}] has been saved"
