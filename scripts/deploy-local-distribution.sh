#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# shellcheck disable=SC2046
source $(pwd)/scripts/env.sh

IMAGE_ABSOLUTE_NAME="${IMAGE_PREFIX}/${IMAGE_NAME}:${IMAGE_VERSION}"

echo "------------------------------------------------------------"
echo "| Deploying the local built tar distribution to remote EC2 |"
echo "------------------------------------------------------------"

echo "Building the distribution ..."
./gradlew build
echo "The new distribution is ready at ${LOCAL_BUILD_DIST}"
echo " "
echo "Preparing build distributions environment..."
ssh "${EC2_USERNAME}"@"${EC2_INSTANCE_IP}" << EOF
    echo " "
    echo "Prepare build distributions environment"

    mkdir -p "${REMOTE_BUILD_DIST_PATH}"

    if [[ -d "${REMOTE_BUILD_DIST_PATH}" ]]; then
        echo "The build distributions folder is ready"
    else
        echo "Error: Build distributions folder couldn't be created..."
    fi
    echo " "
EOF

echo "Copying distribution tar to EC2 instance..."
scp "${LOCAL_BUILD_DIST}" "${EC2_USERNAME}"@"${EC2_INSTANCE_IP}":~/"${REMOTE_BUILD_DIST_TAR}"
scp "${LOCAL_DOCKERFILE}" "${EC2_USERNAME}"@"${EC2_INSTANCE_IP}":~/"${REMOTE_DOCKERFILE}"

echo "SSHing into EC2 instance and deploying the new docker image..."
ssh "${EC2_USERNAME}"@"${EC2_INSTANCE_IP}" << EOF
    echo " "
    echo "Remote deployment procedure "
    cd eqx

    echo "Building [${IMAGE_PREFIX}/${IMAGE_NAME}:${IMAGE_VERSION}] image ..."
    sudo docker build -t "${IMAGE_PREFIX}"/"${IMAGE_NAME}":"${IMAGE_VERSION}" .
    echo "Image [${IMAGE_PREFIX}/${IMAGE_NAME}:${IMAGE_VERSION}] has been built"

    echo "Stop and remove existing [${CONTAINER_NAME}] container if running"
    if sudo docker ps -a --format '{{.Names}}' | grep -E "^$CONTAINER_NAME$"; then
        sudo docker stop "${CONTAINER_NAME}"
        sudo docker rm "${CONTAINER_NAME}"
        echo "Existing container [${CONTAINER_NAME}] stopped and removed."
    else
        echo "The [${CONTAINER_NAME}] container is not running"
    fi

    echo "Start the [${CONTAINER_NAME}] container from the updated [${IMAGE_ABSOLUTE_NAME}] image"
    sudo docker run -dt -p 8383:8383 --name "${CONTAINER_NAME}" "${IMAGE_ABSOLUTE_NAME}"
    echo "New container ${CONTAINER_NAME} running."

    echo "Done"
    echo "---------------------------------------"
    echo " "
EOF

echo "Docker image uploaded, tagged, and container replaced on EC2 instance."
