# Scripts

This directory contains helper scripts for building, testing, and managing Mender OTA updates.

## Prerequisites

Before using these scripts, initialize the build environment:

```bash
source scripts/setup_env.sh
```

## Environment Configuration

Configuration files are in the `config/` directory:

- `config/yocto.env` - Yocto build configuration (image name, machine type, deploy directory)
- `config/mender.env` - Mender server configuration (server URL, PAT, device ID)

## Build Scripts

### build_image.sh

Builds the Yocto image with optional build ID and timestamp.

```bash
# Build with timestamp as build ID
./scripts/build_image.sh -t

# Build with custom build ID
./scripts/build_image.sh -b my-build-id

# Build with build ID and comment
./scripts/build_image.sh -t -m "Fix for issue #123"
```

### clean_output.sh

Removes all `.mender` artifacts from the deploy directory.

```bash
./scripts/clean_output.sh
```

## OTA Test Script

### test_ota.sh

Full end-to-end OTA test script. Cleans output, builds new image, uploads to Mender server, deploys to device, and verifies the update.

```bash
# Run the full test (requires sourced build environment)
source scripts/setup_env.sh && bash scripts/test_ota.sh
```

**Steps:**
1. Read current image-version from device (before deployment)
2. Clean output directory
3. Build new image with timestamp
4. Get artifact info
5. Upload artifact to Mender server
6. Deploy artifact to device
7. Wait 90 seconds for deployment
8. Verify image-version on device (after deployment) and compare

## Mender API Scripts

These scripts interact with the Mender server API.

### upload_artifact.sh

Uploads a `.mender` artifact to the Mender server.

```bash
./scripts/upload_artifact.sh <artifact-file.mender>
```

### deploy_artifact.sh

Creates a deployment for a specific artifact to the configured device.

```bash
./scripts/deploy_artifact.sh <artifact-name>
```

### show_artifact.sh

Shows information about uploaded artifacts.

```bash
./scripts/show_artifact.sh
```

### show_deployment.sh

Shows deployment information.

```bash
# Show latest deployment
./scripts/show_deployment.sh

# Show all deployments
./scripts/show_deployment.sh --all

# Show specific deployment by ID
./scripts/show_deployment.sh <deployment-id>
```

### show_devices.sh

Shows device information from the Mender server.

```bash
./scripts/show_devices.sh
```

## Output Scripts

### show_output.sh

Shows artifact information from the deploy directory, including the content of `/etc/image-version` inside each artifact.

```bash
./scripts/show_output.sh
```

## Quick Start - Full OTA Workflow

```bash
# 1. Initialize environment
source scripts/setup_env.sh

# 2. Clean old artifacts
./scripts/clean_output.sh <<< "y"

# 3. Build new image
./scripts/build_image.sh -t

# 4. Get artifact info
./scripts/show_output.sh

# 5. Upload artifact
ARTIFACT_FILE="build/tmp/deploy/images/raspberrypi3-64/rpi-demo-base-image-raspberrypi3-64.mender"
./scripts/upload_artifact.sh "$ARTIFACT_FILE"

# 6. Deploy to device
./scripts/deploy_artifact.sh <artifact-name> <<< "y"

# 7. Wait and check
sleep 90 && ssh root@192.168.0.82 cat /etc/image-version

# Or run the full test script
bash scripts/test_ota.sh
```
