#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# shellcheck disable=SC2046
source $(pwd)/scripts/env.sh

retry() {
    local -r -i max_attempts="$1"; shift
    local -i waiting_time=2
    local -i attempt_num=1
    # shellcheck disable=SC2145
    echo "Attempting to execute '${@}' for '${max_attempts}' times, waiting ${waiting_time} seconds between calls"
    until "$@"
    do
        if ((attempt_num==max_attempts))
        then
            echo "Attempt ${attempt_num}/${max_attempts} failed and there are no more attempts left!"
            return 0
        else
            echo "Attempt ${attempt_num}/${max_attempts} failed! Trying again in ${waiting_time} seconds..."
            sleep ${waiting_time}
            attempt_num=$(( attempt_num + 1 ))
        fi
    done
}

IMAGE_ABSOLUTE_NAME="${IMAGE_PREFIX}/${IMAGE_NAME}:${IMAGE_VERSION}"

echo "------------------------------------------------------------"
echo "| Deploying the local built tar distribution to remote EC2 |"
echo "------------------------------------------------------------"

echo "Building the distribution ..."
./gradlew build
echo "The new distribution is ready at ${LOCAL_BUILD_DIST}"
echo " "
echo "Preparing build distributions environment..."
# shellcheck disable=SC2087
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
# shellcheck disable=SC2087
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
        echo "Existing container [${CONTAINER_NAME}] has been stopped and has been removed."
    else
        echo "The [${CONTAINER_NAME}] container is not running"
    fi

    echo "Start the [${CONTAINER_NAME}] container from the updated [${IMAGE_ABSOLUTE_NAME}] image"
    sudo docker run -dt -p ${REMOTE_PORT}:${INTERNAL_PORT} --name "${CONTAINER_NAME}" "${IMAGE_ABSOLUTE_NAME}"
    echo "New container ${CONTAINER_NAME} is starting on port ${INTERNAL_PORT} exposed as ${REMOTE_PORT}..."

    echo " "
    echo "Done"
    echo "---------------------------------------"
    echo " "
EOF

echo "Remote testing [${CONTAINER_NAME}]..."
retry 10 curl -sk https://"${EC2_INSTANCE_IP}":"${REMOTE_PORT}"/eqx/status
echo " "
echo "Docker image uploaded, tagged, and container replaced on EC2 instance."
