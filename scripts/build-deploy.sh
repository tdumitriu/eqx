#!/bin/bash

# shellcheck disable=SC2046
source $(pwd)/scripts/env.sh

# Set variables

echo "Copying distribution tar to EC2 instance..."
scp "${LOCAL_BUILD_DIST}" "${EC2_USERNAME}"@"${EC2_INSTANCE_IP}":~/"${REMOTE_BUILD_DIST}"

# SSH into EC2 instance and load Docker image
echo "SSHing into EC2 instance and deploying the new docker image..."
ssh "${EC2_USERNAME}"@"${EC2_INSTANCE_IP}" << EOF
    echo " "
    echo "---------------------------------------"
    echo "Remote deployment procedure "
    echo "---------------------------------------"

    sudo ./scripts/build.sh && sudo ./scripts/run.sh

    echo "Done"
    echo "---------------------------------------"
    echo " "
EOF

echo "Docker image uploaded, tagged, and container replaced on EC2 instance."
