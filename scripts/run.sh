#!/bin/bash

# shellcheck disable=SC2046
source $(pwd)/scripts/env.sh

echo "Running container [${CONTAINER_NAME}] ..."

if docker ps -a --format '{{.Names}}' | grep -E "^$CONTAINER_NAME$"; then
   docker stop "${CONTAINER_NAME}"
   docker rm "${CONTAINER_NAME}"
   echo "Existing container [${CONTAINER_NAME}] stopped and removed."
fi

echo "Starting a new container [${CONTAINER_NAME}] ..."
docker run -dt -p 8383:8383 --name "${CONTAINER_NAME}" "${IMAGE_PREFIX}"/"${IMAGE_NAME}":"${IMAGE_VERSION}"
echo "Container [${CONTAINER_NAME}] has been started"
echo "Container [${CONTAINER_NAME}] is up and running"
