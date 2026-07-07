#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/config/yocto.env"

DEVICE_HOST="192.168.0.82"

echo "========================================"
echo "OTA Test Script"
echo "========================================"
echo

# Step 0: Read current image-version from device (before deployment)
echo "[0/7] Reading current image-version from device..."
echo "========================================"
echo "Current /etc/image-version on device (BEFORE deployment)"
echo "========================================"

ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$DEVICE_HOST" 2>/dev/null || true
CURRENT_VERSION=$(ssh -o StrictHostKeyChecking=no "root@${DEVICE_HOST}" cat /etc/image-version)
echo "$CURRENT_VERSION"
echo

CURRENT_ARTIFACT_NAME=$(echo "$CURRENT_VERSION" | awk -F': ' '/Artifact.*:/ {print $2}')
echo "Current Artifact Name on device: $CURRENT_ARTIFACT_NAME"
echo

# Step 1: Clean output
echo "[1/7] Cleaning output..."
"$SCRIPT_DIR/clean_output.sh" <<< "y"

# Step 2: Build image with timestamp
echo
echo "[2/7] Building image..."
"$SCRIPT_DIR/build_image.sh" -t

# Step 3: Show output and get artifact info
echo
echo "[3/7] Getting artifact info..."
# Use YOCTO_DEPLOY_DIR from yocto.env (relative to PROJECT_DIR)
DEPLOY_DIR="$PROJECT_DIR/$YOCTO_DEPLOY_DIR"

ARTIFACT_FILE=""
ARTIFACT_NAME=""

for artifact in "$DEPLOY_DIR"/*.mender; do
    ARTIFACT_FILE="$artifact"
    ARTIFACT_NAME=$(mender-artifact read "$artifact" \
        | awk -F': ' '/^  Name:/ {print $2}')
    break
done

if [ -z "$ARTIFACT_FILE" ] || [ -z "$ARTIFACT_NAME" ]; then
    echo "Error: No artifact found"
    exit 1
fi

echo "Artifact Name : $ARTIFACT_NAME"
echo "Artifact File : $ARTIFACT_FILE"

# Step 4: Upload and deploy artifact
source "$SCRIPT_DIR/config/mender.env"

echo
echo "[4/7] Uploading artifact..."
"$SCRIPT_DIR/upload_artifact.sh" "$ARTIFACT_FILE"

echo
echo "[5/7] Deploying artifact..."
"$SCRIPT_DIR/deploy_artifact.sh" "$ARTIFACT_NAME" <<< "y"

# Step 6: Wait 60 seconds
echo
echo "[6/7] Waiting 90 seconds for deployment..."
sleep 90

# Step 7: SSH to device and check image-version (after deployment)
echo
echo "========================================"
echo "Checking /etc/image-version on device (AFTER deployment)"
echo "========================================"

ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$DEVICE_HOST" 2>/dev/null || true
NEW_VERSION=$(ssh -o StrictHostKeyChecking=no "root@${DEVICE_HOST}" cat /etc/image-version)
echo "$NEW_VERSION"
echo

NEW_ARTIFACT_NAME=$(echo "$NEW_VERSION" | awk -F': ' '/Artifact.*:/ {print $2}')
echo "New Artifact Name on device: $NEW_ARTIFACT_NAME"
echo

# Compare
echo "========================================"
echo "Comparison Results"
echo "========================================"
echo "Artifact BEFORE deployment: $CURRENT_ARTIFACT_NAME"
echo "Artifact AFTER deployment : $NEW_ARTIFACT_NAME"
echo "Expected artifact name    : $ARTIFACT_NAME"
echo

if [ "$NEW_ARTIFACT_NAME" = "$ARTIFACT_NAME" ]; then
    echo "SUCCESS: Device is running the newly deployed artifact!"
else
    echo "FAILURE: Device is NOT running the expected artifact."
    echo "Expected: $ARTIFACT_NAME"
    echo "Got     : $NEW_ARTIFACT_NAME"
fi

echo
echo "========================================"
echo "OTA Test Complete"
echo "========================================"
