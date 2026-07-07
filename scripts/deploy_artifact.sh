#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/config/mender.env"

if [ $# -gt 1 ]; then
    echo "Usage: $0 [ARTIFACT_NAME]"
    exit 1
fi

if [ $# -eq 1 ]; then
    ARTIFACT_NAME="$1"
fi

DEPLOYMENT_NAME="deploy-${ARTIFACT_NAME}"

echo "========================================"
echo "Creating Mender Deployment"
echo "========================================"
echo "Server     : $SERVER"
echo "Device ID  : $DEVICE_ID"
echo "Artifact   : $ARTIFACT_NAME"
echo "Deployment : $DEPLOYMENT_NAME"
echo

read -rp "Continue? [y/N] " ANSWER
if [[ ! "$ANSWER" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

curl -i -X POST \
    "$SERVER/api/management/v1/deployments/deployments" \
    -H "Authorization: Bearer $MENDER_PAT" \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"$DEPLOYMENT_NAME\",
        \"artifact_name\": \"$ARTIFACT_NAME\",
        \"devices\": [
            \"$DEVICE_ID\"
        ]
    }"

echo
echo "Deployment created successfully."
