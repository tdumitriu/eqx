#!/bin/bash

# shellcheck disable=SC2046
source $(pwd)/scripts/env.sh

docker run -dt -p 8383:8383 --name eqx "${IMAGE_PREFIX}"/"${IMAGE_NAME}":"${IMAGE_VERSION}"
