#!/bin/bash

# shellcheck disable=SC2046
source $(pwd)/scripts/env.sh

# Set variables

LOCAL_IMAGE_TAR="./${HOME_EQX}/${IMAGE_PATH}/${IMAGE_NAME}.tar"
REMOTE_IMAGE_TAR="${REMOTE_PATH}/${IMAGE_NAME}.tar"
IMAGE_ABSOLUTE_NAME="${IMAGE_PREFIX}/${IMAGE_NAME}:${IMAGE_VERSION}"

# Copy Docker image to EC2 instance
echo "Copying compressed docker image to EC2 instance..."
scp "${LOCAL_IMAGE_TAR}" "${EC2_USERNAME}"@"${EC2_INSTANCE_IP}":~/"${REMOTE_PATH}"

# SSH into EC2 instance and load Docker image
echo "SSHing into EC2 instance and deploying the new docker image..."
ssh "${EC2_USERNAME}"@"${EC2_INSTANCE_IP}" << EOF
    echo " "
    echo "---------------------------------------"
    echo "Remote deployment procedure "
    echo "---------------------------------------"
    echo "Starting the [${IMAGE_NAME}] image deployment"
    echo " "
    echo "Loading ${REMOTE_HOME}/${REMOTE_IMAGE_TAR}"

    sudo docker load -i "${REMOTE_HOME}/${REMOTE_IMAGE_TAR}"

    # Stop and remove existing [${CONTAINER_NAME}] container if running
    echo "Stop and remove existing [${CONTAINER_NAME}] container if running"
    if sudo docker ps -a --format '{{.Names}}' | grep -E "^$CONTAINER_NAME$"; then
        sudo docker stop "${CONTAINER_NAME}"
        sudo docker rm "${CONTAINER_NAME}"
        echo "Existing container ${CONTAINER_NAME} stopped and removed."
    fi

    # Run a new [${CONTAINER_NAME}] container from the updated [${IMAGE_ABSOLUTE_NAME}] image
    echo "Run a new container from the updated image"
    sudo docker run -dt -p 8383:8383 --name "${CONTAINER_NAME}" "${IMAGE_ABSOLUTE_NAME}"
    echo "New container ${CONTAINER_NAME} running."
    echo "Done"
    echo "---------------------------------------"
    echo " "
EOF

echo "Docker image uploaded, tagged, and container replaced on EC2 instance."
