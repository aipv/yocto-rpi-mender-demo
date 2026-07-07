#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/config/yocto.env"

DEPLOY_DIR="$PROJECT_DIR/$YOCTO_DEPLOY_DIR"

if [ ! -d "$DEPLOY_DIR" ]; then
    echo "Error: deploy directory not found:"
    echo "  $DEPLOY_DIR"
    exit 1
fi

shopt -s nullglob

for artifact in "$DEPLOY_DIR"/*.mender; do

    ARTIFACT_NAME=$(mender-artifact read "$artifact" \
        | awk -F': ' '/^  Name:/ {print $2}')

    echo "======================================================================"
    echo "Artifact Name : $ARTIFACT_NAME"
    echo "File          : $artifact"
    echo

done
