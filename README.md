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
- Device connects to a locally hosted Mender Server using the hostname `docker.mender.io`
- Automatic OTA updates

### Custom Yocto Development

The custom layer `meta-rpi-demo` includes:

- Custom image recipe
- Image version package
- Mender server certificate recipe
- Demo application recipe
- Build configuration templates

### Installed Packages

- `tree` - Directory listing utility
- `openssh` - SSH client and server
- `openssh-sshd` - SSH daemon
- `mender-server-cert-config` - Mender server TLS certificates

## Repository Structure

```text
yocto-rpi-mender-demo/
├── meta-rpi-demo/
│   ├── conf/
│   ├── recipes-core/
│   └── recipes-support/
├── scripts/
│   ├── setup_env.sh
│   ├── build_image.sh
│   ├── upload_artifact.sh
│   ├── deploy_artifact.sh
│   └── test_ota.sh
└── README.md
```

The upstream Yocto layers (`poky`, `meta-openembedded`, `meta-raspberrypi`, `meta-mender`, and `meta-mender-community`) are pulled in as Git submodules.

# Setup

## Prerequisites

- **OS:** Ubuntu 22.04 or newer
- **Disk:** 80 GB or more free space
- **Memory:** 8 GB RAM minimum

## Install Build Dependencies

```bash
sudo apt update
sudo apt install -y build-essential chrpath cpio diffstat gcc g++ git python3 python3-pip unzip texinfo flex bison bc zstd jq u-boot-tools dosfstools mtools parted libssl-dev libncurses-dev uuid-dev
```

## Initialize Submodules

```bash
cd yocto-rpi-mender-demo
git submodule update --init --recursive
```

## Initialize Build Environment

```bash
source scripts/setup_env.sh build
```

## Build Image

```bash
bitbake rpi-demo-base-image
```

Artifacts are generated in:

```text
build/tmp/deploy/images/raspberrypi3-64/
```

## Flash the SD Card

```bash
bunzip2 -k build/tmp/deploy/images/raspberrypi3-64/rpi-demo-base-image-raspberrypi3-64.wic.bz2

sudo dd if=build/tmp/deploy/images/raspberrypi3-64/rpi-demo-base-image-raspberrypi3-64.wic of=/dev/sdX bs=4M status=progress conv=fsync
```

Alternatively, use the Balena Etcher desktop application.

## First Boot

Determine the Raspberry Pi IP address from the boot messages or your router:

```bash
ssh root@<device-ip>
```

# Mender Server Setup

Start the Mender Server:

```bash
cd ../mender-server
docker compose up -d
```

Add the Mender Server IP address to `/etc/hosts` so that `docker.mender.io` resolves to your local server.

Create `scripts/config/mender.env` from `scripts/config/mender.env.example` and update `MENDER_PAT`.

# OTA Update

## OTA Workflow

```text
Build Image
  ↓
Verify Generated Artifact
  ↓
Upload Artifact
  ↓
Create Deployment
  ↓
Device Downloads Update
  ↓
Automatic Reboot
  ↓
OTA Updated
```

## Helper Scripts

| Script | Description |
|---------|-------------|
| `setup_env.sh` | Initializes the Yocto build environment. |
| `build_image.sh` | Builds the custom Yocto image and the Mender OTA artifact (`.mender`). |
| `show_output.sh` | Displays the image version and Mender artifact information after building. |
| `clean_output.sh` | Removes generated build artifacts. |
| `upload_artifact.sh` | Uploads the generated Mender artifact. |
| `deploy_artifact.sh` | Creates a deployment on the Mender Server. |
| `show_devices.sh` | Lists registered devices. |
| `show_artifact.sh` | Displays available artifacts. |
| `show_deployment.sh` | Displays deployment progress. |
| `test_ota.sh` | Runs the complete OTA workflow automatically. |

## Quick Start

```bash
source scripts/setup_env.sh build
./scripts/clean_output.sh <<< "y"
./scripts/build_image.sh -t
./scripts/show_output.sh
ARTIFACT_FILE="build/tmp/deploy/images/raspberrypi3-64/rpi-demo-base-image-raspberrypi3-64.mender"
./scripts/upload_artifact.sh "$ARTIFACT_FILE"
./scripts/deploy_artifact.sh <artifact-name> <<< "y"
```

# Future Improvements

- Artifact metadata
- GitHub Actions CI
- QEMU support
- Secure Boot
- Software signing

# License

This project is provided for demonstration and educational purposes.
