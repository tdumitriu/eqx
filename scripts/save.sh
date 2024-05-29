#!/bin/bash

# shellcheck disable=SC2046
source $(pwd)/scripts/env.sh

docker save --output "${EQX_HOME}"/"${IMAGE_PATH}"/"${IMAGE_NAME}"_"${IMAGE_VERSION}".tar \
       "${IMAGE_PREFIX}"/"${IMAGE_NAME}":"${IMAGE_VERSION}"
