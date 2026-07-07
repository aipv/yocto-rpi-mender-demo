#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config/mender.env"

DEPLOYMENT_NAME="deploy-${ARTIFACT_NAME}"

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
