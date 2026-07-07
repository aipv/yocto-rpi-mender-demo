#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config/mender.env"

if [ $# -ne 1 ]; then
    echo "Usage: $0 <artifact-file.mender>"
    exit 1
fi

ARTIFACT_FILE="$1"

if [ ! -f "$ARTIFACT_FILE" ]; then
    echo "Error: artifact file not found: $ARTIFACT_FILE"
    exit 1
fi

curl -i -X POST \
    "$SERVER/api/management/v1/deployments/artifacts" \
    -H "Authorization: Bearer $MENDER_PAT" \
    -F "artifact=@${ARTIFACT_FILE}"
