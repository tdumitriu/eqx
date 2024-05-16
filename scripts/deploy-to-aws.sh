#!/bin/bash

# Set variables
EC2_INSTANCE_IP="your_ec2_instance_ip"
EC2_USERNAME="your_ec2_username"
LOCAL_IMAGE="your_local_docker_image_name"
REMOTE_IMAGE="your_remote_docker_image_name"
DOCKERFILE_PATH="path_to_your_dockerfile_on_remote_instance"
SSH_KEY="path_to_your_ssh_key"
CONTAINER_NAME="your_container_name"

# Copy Docker image to EC2 instance
echo "Copying Docker image to EC2 instance..."
scp -i "$SSH_KEY" "$LOCAL_IMAGE" "$EC2_USERNAME"@"$EC2_INSTANCE_IP":~/

# SSH into EC2 instance and load Docker image
echo "SSHing into EC2 instance and loading Docker image..."
ssh -i "$SSH_KEY" "$EC2_USERNAME"@"$EC2_INSTANCE_IP" << EOF
    sudo docker load -i "$LOCAL_IMAGE"
    sudo docker tag "$LOCAL_IMAGE" "$REMOTE_IMAGE"
    sudo docker build -t "$REMOTE_IMAGE" "$DOCKERFILE_PATH"

    # Stop and remove existing container if running
    if sudo docker ps -a --format '{{.Names}}' | grep -Eq "^$CONTAINER_NAME$"; then
        sudo docker stop "$CONTAINER_NAME"
        sudo docker rm "$CONTAINER_NAME"
        echo "Existing container $CONTAINER_NAME stopped and removed."
    fi

    # Run a new container from the updated image
    sudo docker run -d --name "$CONTAINER_NAME" "$REMOTE_IMAGE"
    echo "New container $CONTAINER_NAME running."
EOF

echo "Docker image uploaded, tagged, and container replaced on EC2 instance."
