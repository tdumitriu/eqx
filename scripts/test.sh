#!/bin/bash

# shellcheck disable=SC2046
source $(pwd)/scripts/env.sh


echo "Testing [${CONTAINER_NAME}] on [${HOSTNAME}:${PORT}]..."
# shellcheck disable=SC2086
response=$(curl -sk https://${HOSTNAME}:${PORT}/eqx/status | jq '.')
echo "${response}"

if [[ -n "${response}" ]]; then
  echo "Container [${CONTAINER_NAME}] is up and running"
  response=$(curl -sk https://${HOSTNAME}:${PORT}/eqx/health/mem | jq '.')
  echo "${response}"
else
  echo "Container [${CONTAINER_NAME}] is not up"
fi
