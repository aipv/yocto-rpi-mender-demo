# Raspberry Pi Mender OTA Demo

A complete **Yocto Project** demonstration showing how to build a custom Embedded Linux image for **Raspberry Pi 3 Model B+** with **Mender OTA** support.

This project demonstrates practical Embedded Linux development using the Yocto Project, including custom layers, BitBake recipes, system customization, and over-the-air software updates with Mender.

## Features

### Embedded Linux

- Yocto Project (Scarthgap)
- Raspberry Pi 3 Model B+ (64-bit)
- Linux Kernel 6.x
- U-Boot bootloader
- OpenSSH server
- Custom image configuration

### Mender OTA

- Mender 5.0.0 client pre-configured and enabled on the device
- Device connects to Mender server at `docker.mender.io`
- Automatic update

### Custom Yocto Development

The custom layer `meta-rpi-demo` includes:

- Custom image recipe
- Image version package
- Mender server certificate recipe
- Demo application recipe
- Build configuration templates

### Installed Packages
- `tree` - directory listing utility
- `openssh` - SSH client and server
- `openssh-sshd` - SSH daemon
- `kernel-image` - kernel modules and image
- `kernel-devicetree` - device tree blobs
- `mender-server-cert-config` - Mender server TLS certificates


## Repository Structure

```
yocto-rpi-mender-demo/
├── meta-rpi-demo/
│   ├── conf/
│   ├── recipes-core/
│   └── recipes-support/
├── scripts/
│   ├── setup_env.sh
│   ├── build_image.sh
│   ├── upload_artifact.sh
│   ├── deplay_artifact.sh
│   └── test_ota.sh
└── README.md
```

The upstream Yocto layers (`poky`, `meta-openembedded`, `meta-raspberrypi`, `meta-mender`, `meta-mender-community`) are pulled in as Git submodules.

# Setup

## Prerequisites

- **OS**: Linux (Ubuntu 22.04+ recommended)
- **Disk**: 80GB+ free space
- **Memory**: 8GB+ RAM
- **Packages**: Required build dependencies

## Install Build Dependencies

```bash
sudo apt update
sudo apt install -y \
    build-essential \
    chrpath \
    cpio \
    diffstat \
    gcc \
    g++ \
    git \
    python3 \
    python3-pip \
    unzip \
    texinfo \
    flex \
    bison \
    bc \
    zstd \
    jq \
    u-boot-tools \
    dosfstools \
    mtools \
    parted \
    libssl-dev \
    libncurses-dev \
    uuid-dev
```

## Initialize Submodules

```bash
cd yocto-rpi-mender-demo
git submodule update --init --recursive
```

## Initialize Build Environment

```bash
source scripts/setup-build.sh build
```

This creates a `build` directory (or uses existing) with proper configuration from `meta-rpi-demo/conf/templates/default/`.

```bash
bitbake-layers show-layers
```

Expected output should include:
- `meta`
- `meta-poky`
- `meta-yocto-bsp`
- `meta-oe`
- `meta-raspberrypi`
- `meta-mender-core`
- `meta-mender-raspberrypi`
- `meta-rpi-demo`

## Build Image

```bash
bitbake rpi-demo-base-image
```

After successful build, artifacts are in:
```
build/tmp/deploy/images/raspberrypi3-64/
```
Key files:
- `.wic.bz2` - Raw SD card image (for flashing)
- `.mender` - Mender update artifact (for OTA updates)
- `.wic.bmap` - Block map for `dd` efficiency

## Flashing to SD Card

1. Decompress the image:
   ```bash
   bunzip2 -k build/tmp/deploy/images/raspberrypi3-64/rpi-demo-base-image-raspberrypi3-64.wic.bz2
   ```

2. Flash using `dd`:
   ```bash
   sudo dd if=rpi-demo-base-image-raspberrypi3-64.wic of=/dev/sdX bs=4M status=progress
   ```

### Option 2: Using Balena CLI

```bash
balenaetcher -d /dev/sdX build/tmp/deploy/images/raspberrypi3-64/rpi-demo-base-image-raspberrypi3-64.wic.bz2
```

## First Boot

After booting the Raspberry Pi, trying get IP address from Boot Information or Router:

```bash
ssh root@<device-ip>
```

The `debug-tweaks` option is enabled, SSH login does not require a password.


# Mender Server Setup

## Install local Mender Server

## Start Mender Server

```bash
cd ../mender-server
docker compose up -d
```
## Mender Server Hostname Configuration

And Mender Server'IP address in `/etc/hosts` to resolve `docker.mender.io` to your PC.

## Access the Mender Server via WebUI

On first login, create an account via the UI.

## Get Personal access token from Mender Server

After login, get a Personal access token (PAT) from the Mender Server.

## Configuration Menter Server in the project

Createa scripts/config/mender.env based on the mender.env.example file.

Update MENDER_PAT in the configuration file.


# OTA Update 

## OTA Workflow

The OTA workflow is:

```
Build Image
      │
      ▼
Check mender file and artifact name
      │
      ▼
Upload Artifact to Mender Server
      │
      ▼
Create Deployment
      │
      ▼
Device Downloads Update
      │
      ▼
Automatic Reboot
      │
      ▼
OTA Updated
```

## Helper Scripts

| Script | Description |
|---------|-------------|
| `setup_env.sh` | Initializes the Yocto build environment. |
| `build_image.sh` | Builds the custom Yocto image and the Mender OTA artifact (`.mender`). |
| `show_output.sh` | Displays image and mender artifact name after building. |
| `clean_output.sh` | Removes generated build artifacts to prepare for a clean build or deployment. |
| `upload_artifact.sh` | Uploads the generated Mender artifact to the Mender Server. |
| `deploy_artifact.sh` | Creates a deployment on the Mender Server to deliver the uploaded artifact. |
| `show_devices.sh` | Lists registered devices and their current status on the Mender Server. |
| `show_artifact.sh` | Display the artifacts currently available on the Mender Server. |
| `show_deployment.sh` | Shows the status and progress of active or completed OTA deployments. |
| `test_ota.sh` | Automates the complete OTA workflow by building the image, uploading an artifact, creating a deployment, and verifying the result. |

## Quick Start

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
```

Or run the full test script
```
bash scripts/test_ota.sh
```
# Future Improvements

- Artifact Provides / Depends metadata
- Automatic version generation from Git
- GitHub Actions CI build
- QEMU support
- Secure Boot demonstration
- Software signing
- Docker-based build environment

---

# License

This project is provided for demonstration and educational purposes.

