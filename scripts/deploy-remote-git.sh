#!/bin/bash

# shellcheck disable=SC2046
source $(pwd)/scripts/env.sh

# Set variables
IMAGE_ABSOLUTE_NAME="${IMAGE_PREFIX}/${IMAGE_NAME}:${IMAGE_VERSION}"
REPO_GIT="git@github.com:tdumitriu/eqx.git"
REPO_DIR="eqx"

# GITCopy Docker image to EC2 instance
echo "Refresh EC2 git repo and redeploy the docker image ..."

# SSH into EC2 instance and load Docker image
echo "SSHing into EC2 instance and deploying the new docker image..."
ssh "${EC2_USERNAME}"@"${EC2_INSTANCE_IP}" << 'EOF'
    echo " "
    echo "---------------------------------------"
    echo "Remote refresh deployment"
    echo "---------------------------------------"

    if command -v git &> /dev/null; then
        echo "Git is already installed, moving on"
    else
        echo "Warning: git is not installed."
        echo "Updating package list..."
        sudo apt-get update -y
        echo "Installing git..."
        sudo apt-get install -y git
    fi

    if [[ -d "${REPO_DIR}/.git" ]]; then
        echo "Repository already cloned. Pulling latest changes..."
        cd "${REPO_DIR}" && git pull
    else
        echo "Cloning repository ${REPO_GIT}..."
        git clone "${REPO_GIT}" "${REPO_DIR}"
        cd "${REPO_DIR}"
    fi

    echo " "
    echo "The git repo has been refreshed"
    echo " "
    echo "Building the new [${IMAGE_ABSOLUTE_NAME}] image"
    echo " "

    ./gradlew build
    sudo ./scripts/build.sh && sudo ./scripts/run.sh

    echo "Done"
    echo "---------------------------------------"
    echo " "
EOF

echo "Docker image uploaded, tagged, and container replaced on EC2 instance."
