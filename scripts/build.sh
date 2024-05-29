#!/bin/bash

# shellcheck disable=SC2046
source $(pwd)/scripts/env.sh

docker build -t "${IMAGE_PREFIX}"/"${IMAGE_NAME}":"${IMAGE_VERSION}" .
