#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config/yocto.env"

echo "========================================"
echo "Building Yocto image"
echo "========================================"
echo "PWD   : $(pwd)"
echo "Image : $YOCTO_IMAGE"
echo

bitbake "$YOCTO_IMAGE"

echo
echo "========================================"
echo "Build completed successfully."
echo "========================================"
