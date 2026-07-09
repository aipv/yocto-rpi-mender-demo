
# Raspberry Pi Mender OTA Demo

A complete **Yocto Project** demonstration showing how to build a custom Embedded Linux image for **Raspberry Pi 3 Model B+** with **Mender OTA**.

This repository demonstrates practical Embedded Linux development using the Yocto Project, including custom layers, BitBake recipes, image customization, secure OTA updates, and deployment automation.

---

# Features

## Embedded Linux

- Yocto Project (Scarthgap)
- Raspberry Pi 3 Model B+ (64-bit)
- Linux Kernel 6.x
- U-Boot bootloader
- OpenSSH server
- Custom image recipe

## Mender OTA

- Mender Client 5.x integrated into the image
- HTTPS communication using a custom server certificate
- Automatic OTA deployment
- Image version tracking
- Helper scripts for upload and deployment

## Custom Yocto Layer

The custom layer `meta-rpi-demo` contains:

- Custom image recipe
- Image version recipe
- Mender server certificate recipe
- Build configuration templates

---

# Repository Structure

```text
yocto-rpi-mender-demo/
├── ext/
│   ├── poky/
│   ├── meta-openembedded/
│   ├── meta-raspberrypi/
│   ├── meta-mender/
│   └── meta-mender-community/
├── meta-rpi-demo/
│   ├── conf/
│   ├── recipes-core/
│   └── recipes-support/
├── scripts/
│   ├── config/
│   │   ├── yocto.env.example
│   │   └── mender.env.example
│   ├── setup_env.sh
│   ├── build_image.sh
│   ├── clean_output.sh
│   ├── show_output.sh
│   ├── upload_artifact.sh
│   ├── deploy_artifact.sh
│   ├── show_devices.sh
│   ├── show_artifact.sh
│   ├── show_deployment.sh
│   └── test_ota.sh
└── README.md
```

The upstream Yocto layers (`ext/poky`, `ext/meta-openembedded`, `ext/meta-raspberrypi`, `ext/meta-mender`, and `ext/meta-mender-community`) are included as Git submodules.

---

# Prerequisites

- Ubuntu 22.04 or newer
- 8 GB RAM minimum (16 GB recommended)
- 80 GB free disk space

Install the required packages:

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

---

# Clone the Repository

```bash
git clone <repository-url>
cd yocto-rpi-mender-demo
git submodule update --init --recursive
```

---

# Configure the Project

Create local configuration files:

```bash
cp scripts/config/yocto.env.example scripts/config/yocto.env
cp scripts/config/mender.env.example scripts/config/mender.env
```

Update the configuration values to match your build environment and Mender Server.

---

# Initialize the Build Environment

```bash
source scripts/setup_env.sh build
```

Verify the layers:

```bash
bitbake-layers show-layers
```

---

# Build the Image

```bash
bitbake rpi-demo-base-image
```

Artifacts are generated in:

```text
build/tmp/deploy/images/raspberrypi3-64/
```

Important outputs:

- `.wic.bz2` — Raspberry Pi SD card image
- `.mender` — OTA update artifact
- `.wic.bmap` — block map for faster flashing

---

# Flash the SD Card

```bash
bunzip2 -k build/tmp/deploy/images/raspberrypi3-64/rpi-demo-base-image-raspberrypi3-64.wic.bz2

sudo dd \
    if=build/tmp/deploy/images/raspberrypi3-64/rpi-demo-base-image-raspberrypi3-64.wic \
    of=/dev/sdX \
    bs=4M \
    status=progress \
    conv=fsync
```

You can also flash the generated `.wic.bz2` image using **Balena Etcher**.

---

# First Boot

Find the Raspberry Pi IP address from your router or boot messages.

```bash
ssh root@<device-ip>
```

If `debug-tweaks` is enabled, SSH login does not require a password.

---

# Mender Server Setup

Start your local Mender Server:

```bash
cd ../mender-server
docker compose up -d
```

Add the server IP to `/etc/hosts` so that `docker.mender.io` resolves to your local server.

Log in to the Mender Web UI and generate a **Personal Access Token (PAT)**.

Update `scripts/config/mender.env` with the generated PAT.

---

# OTA Workflow

```text
Build Image
      │
      ▼
Verify Generated Artifact
      │
      ▼
Upload Artifact
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
Verify New Image
```

---

# Helper Scripts

| Script | Description |
|---------|-------------|
| `setup_env.sh` | Initializes the Yocto build environment. |
| `build_image.sh` | Builds the demo image and OTA artifact. |
| `clean_output.sh` | Removes previously generated artifacts. |
| `show_output.sh` | Displays the generated image and artifact information. |
| `upload_artifact.sh` | Uploads a Mender artifact to the server. |
| `deploy_artifact.sh` | Creates a deployment for the selected artifact. |
| `show_devices.sh` | Lists registered devices. |
| `show_artifact.sh` | Lists available artifacts. |
| `show_deployment.sh` | Displays deployment progress. |
| `test_ota.sh` | Executes the complete OTA workflow automatically. |

---

# Quick Start

```bash
source scripts/setup_env.sh build

./scripts/clean_output.sh <<< "y"

./scripts/build_image.sh -t

./scripts/show_output.sh

ARTIFACT_FILE="build/tmp/deploy/images/raspberrypi3-64/rpi-demo-base-image-raspberrypi3-64.mender"

./scripts/upload_artifact.sh "$ARTIFACT_FILE"

./scripts/deploy_artifact.sh <artifact-name>

bash scripts/test_ota.sh
```

---

# Future Improvements

- Artifact metadata (Provides / Depends)
- Automatic version generation from Git
- GitHub Actions CI
- QEMU support
- Secure Boot
- Artifact signing
- Docker-based build environment

---

# License

This project is provided for demonstration and educational purposes.
