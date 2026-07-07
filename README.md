# Raspberry Pi Mender Demo

Yocto-based build system for Raspberry Pi 3 Model B+ with Mender OTA update support.

## Overview

This project builds a Raspberry Pi 3 B+ image with Mender client for OTA firmware updates. The image connects to a Mender server for centralized firmware management.

- **Target**: Raspberry Pi 3 Model B+ (64-bit)
- **Base**: Poky Scarthgap + Mender 5.0.0
- **Artifact Name**: `release-1`

## Included Features

### Mender OTA Update Client
- Mender 5.0.0 client pre-configured and enabled on the device
- Dual rootfs partition for atomic updates and automatic rollback
- Artifact name: `release-1`
- Device connects to Mender server at `docker.mender.io`
- Automatic update checks and status reporting

### Bootloader
- U-Boot for Raspberry Pi 3 B+ (64-bit)
- Mender-compatible boot flow configured
- Environment stored in `fw_env.config`

### Linux Kernel
- Kernel 6.6.63 (mainline-based)
- Device tree: `bcm2710-rpi-3-b-plus.dtb`

### Installed Packages
- `tree` - directory listing utility
- `openssh` - SSH client and server
- `openssh-sshd` - SSH daemon
- `kernel-image` - kernel modules and image
- `kernel-devicetree` - device tree blobs
- `mender-server-cert-config` - Mender server TLS certificates

### Network Configuration
- Pre-configured `/etc/hosts` entries for `docker.mender.io` and `s3.docker.mender.io`
- DHCP-enabled ethernet
- Hostname resolution for Mender server

## Repository Structure

```
yocto-rpi-mender-demo/
├── poky/                    # Yocto BSP layer
├── meta-openembedded/      # OpenEmbedded layer
├── meta-raspberrypi/       # Raspberry Pi support
├── meta-mender/            # Mender core
├── meta-mender-community/  # Mender community integrations
├── meta-rpi-demo/          # Custom demo layer
├── build/                  # Build directory
├── downloads/              # Downloaded sources cache
├── sstate-cache/           # Shared state cache
└── scripts/
    └── setup-build.sh      # Build environment setup script
```

## Prerequisites

- **OS**: Linux (Ubuntu 22.04+ recommended)
- **Disk**: 100GB+ free space
- **Memory**: 8GB+ RAM
- **Packages**: Required build dependencies

### Install Build Dependencies

```bash
sudo apt update && sudo apt install -y \
    git \
    build-essential \
    python3 \
    python3-pip \
    diffstat \
    mtools \
    u-boot-tools \
    zip \
    bison \
    g++ \
    gcc \
    gnat \
    autoconf \
    automake \
    libtool \
    libncurses-dev \
    libssl-dev \
    bc \
    flex \
    uuid-dev \
    zlib1g-dev \
    dosfstools \
    e2fsprogs \
    mtools \
    parted \
    pkg-config \
    fakeroot \
    cpio \
    xz-utils \
    zstd
```

## Setup

### 1. Initialize Submodules

```bash
cd yocto-rpi-mender-demo
git submodule update --init --recursive
```

### 2. Initialize Build Environment

```bash
source scripts/setup-build.sh build
```

This creates a `build` directory (or uses existing) with proper configuration from `meta-rpi-demo/conf/templates/default/`.

### 3. Verify Layers

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

## Build

### Full Image Build

```bash
bitbake rpi-demo-base-image
```

### Build Outputs

After successful build, artifacts are in:
```
build/tmp/deploy/images/raspberrypi3-64/
```

Key files:
- `.wic.bz2` - Raw SD card image (for flashing)
- `.mender` - Mender update artifact (for OTA updates)
- `.wic.bmap` - Block map for `dd` efficiency

### Building with Shared Cache

The project uses shared `downloads/` and `sstate-cache/` directories to speed up rebuilds and reduce disk space.

## Flashing to SD Card

### Option 1: Using Balena Etcher

1. Decompress the image:
   ```bash
   bunzip2 -k build/tmp/deploy/images/raspberrypi3-64/rpi-demo-base-image-raspberrypi3-64.wic.bz2
   ```

2. Flash using Etcher or `dd`:
   ```bash
   sudo dd if=rpi-demo-base-image-raspberrypi3-64.wic of=/dev/sdX bs=4M status=progress
   ```

### Option 2: Using Balena CLI

```bash
balenaetcher -d /dev/sdX build/tmp/deploy/images/raspberrypi3-64/rpi-demo-base-image-raspberrypi3-64.wic.bz2
```

## Network Configuration

The image is pre-configured with:
- `/etc/hosts` entry: `192.168.0.88 docker.mender.io s3.docker.mender.io`

Update `meta-rpi-demo/recipes-core/images/rpi-demo-base-image.bb` if your Mender server IP differs.

## Mender Server Setup

### Start Mender Server

```bash
cd ../mender-server
docker compose up -d
```

The Mender GUI is available at `http://localhost:8090`.

### Default Credentials

On first login, create an account via the UI.

### Server Hostname Configuration

If running on a custom IP, update the Mender server hostname:
```bash
# In mender-server/.env or docker-compose environment
MENDER_HOSTNAME=docker.mender.io
```

And update device's `/etc/hosts` to resolve `docker.mender.io` to your server IP.

## Uploading Artifacts to Mender

### Using Mender CLI

Install `mender-artifact` on your build machine:
```bash
curl -fsSL https://get.mender.io | bash
```

### Upload Artifact

1. Log into Mender UI at `http://localhost:8090`
2. Go to **Releases**
3. Click **Upload artifact**
4. Select the `.mender` file from `build/tmp/deploy/images/raspberrypi3-64/`

Or use the API:

```bash
# Get auth token from UI, then:
curl -X POST \
  -H "Authorization: Bearer <token>" \
  -F "artifact=@build/tmp/deploy/images/raspberrypi3-64/rpi-demo-base-image-raspberrypi3-64.mender" \
  http://localhost/api/management/v1/deployments/artifacts
```

## Deploying Updates

### From Mender UI

1. Go to **Devices** - verify your device appears and shows "connected"
2. Go to **Releases** - select your uploaded artifact
3. Click **Create deployment**
4. Select target device(s)
5. Submit deployment

### Device Status

Monitor deployment status from:
- **Mender UI**: Devices tab → Select device → Deployment status
- **Device shell**: `journalctl -u mender`

## Customizing the Build

### Change Mender Artifact Name

Edit `meta-rpi-demo/conf/features/mender.inc`:
```bash
MENDER_ARTIFACT_NAME = "release-2"
```

### Add Packages to Image

Edit `meta-rpi-demo/recipes-core/images/rpi-demo-base-image.bb`:
```bash
IMAGE_INSTALL:append = " \
    your-package \
    another-package \
"
```

### Change Server IP

Edit `meta-rpi-demo/recipes-core/images/rpi-demo-base-image.bb`:
```bash
add_mender_demo_hosts() {
    echo "YOUR_SERVER_IP docker.mender.io s3.docker.mender.io" \
        >> ${IMAGE_ROOTFS}${sysconfdir}/hosts
}
```

### Change Machine Type

Edit `build/conf/local.conf`:
```bash
MACHINE ??= "raspberrypi3-64"
```

Supported machines in `meta-raspberrypi`:
- `raspberrypi0-wifi`
- `raspberrypi3`
- `raspberrypi3-64`
- `raspberrypi4`
- `raspberrypi4-64`

## Troubleshooting

### Device Not Connecting

1. Check network: `ping docker.mender.io`
2. Check Mender service: `systemctl status mender`
3. View logs: `journalctl -u mender -f`
4. Verify server IP in `/etc/hosts`

### Build Failures

1. Clean and rebuild:
   ```bash
   bitbake rpi-demo-base-image -c cleanall
   bitbake rpi-demo-base-image
   ```

2. Verify submodules:
   ```bash
   git submodule update --init --recursive
   ```

### Deployment Failures

1. Check device connectivity in Mender UI
2. Verify artifact compatibility with device type
3. Check deployment logs: Mender UI → Device → Deployment history

### SSH Access to Device

The image includes OpenSSH server. After flashing:

1. Find device IP (via DHCP or `nmap`)
2. Connect:
   ```bash
   ssh root@<device-ip>
   ```
   (Password may be empty or "root" depending on configuration)

## Version Information

- **Yocto**: Scarthgap
- **Mender**: 5.0.0
- **Raspberry Pi**: 3 B+ (64-bit)
- **Kernel**: 6.6.63

## References

- [Mender Documentation](https://docs.mender.io/)
- [Yocto Project](https://www.yoctoproject.org/)
- [Raspberry Pi Yocto Layer](https://github.com/agherzan/meta-raspberrypi)
- [Mender Yocto Layer](https://github.com/mendersoftware/meta-mender)
