#!/bin/bash

# shellcheck disable=SC2046
source $(pwd)/scripts/env.sh

ssh "${EC2_USERNAME}"@"${EC2_INSTANCE_IP}" << EOF
    echo " "
    echo "---------------------------------------"
    echo "Prepare build distributions environment"
    echo "---------------------------------------"

    mkdir -p "${REMOTE_BUILD_DIST_PATH}"

    if [[ -d "${REMOTE_BUILD_DIST_PATH}" ]]; then
        echo "The build distributions folder is ready"
    else
        echo "Error: Build distributions folder couldn't be created..."
    fi
    echo "---------------------------------------"
    echo " "
EOF

echo "Copying distribution tar to EC2 instance..."
scp "${LOCAL_BUILD_DIST}" "${EC2_USERNAME}"@"${EC2_INSTANCE_IP}":~/"${REMOTE_BUILD_DIST_TAR}"

# SSH into EC2 instance and load Docker image
echo "SSHing into EC2 instance and deploying the new docker image..."
ssh "${EC2_USERNAME}"@"${EC2_INSTANCE_IP}" << EOF
    echo " "
    echo "---------------------------------------"
    echo "Remote deployment procedure "
    echo "---------------------------------------"

    cd eqx && sudo ./scripts/build.sh && sudo ./scripts/run.sh

    echo "Testing status ..."
    curl -ks https://localhost:8383/eqx/status | jq '.'
    echo "Done"
    echo "---------------------------------------"
    echo " "
EOF

echo "Docker image uploaded, tagged, and container replaced on EC2 instance."
