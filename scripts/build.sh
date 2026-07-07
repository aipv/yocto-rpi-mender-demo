#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/config/yocto.env"

BUILD_ID=""
COMMENT=""
USE_TIMESTAMP=false

usage() {
cat <<EOF
Usage: $(basename "$0") [options]

Build the Yocto image.

Options:
  -b <build_id>    Set IMAGE_BUILD_ID
  -m <comment>     Set IMAGE_COMMENT
  -t               Use current timestamp as IMAGE_BUILD_ID
  -h               Show this help

Examples:
  $(basename "$0")
  $(basename "$0") -t
  $(basename "$0") -m "Fix OTA workflow"
  $(basename "$0") -t -m "Fix OTA workflow"
  $(basename "$0") -b a13c8f2
  $(basename "$0") -b v1.0.0 -m "First public release"
EOF
}

while getopts ":b:m:th" opt; do
    case "$opt" in
        b)
            BUILD_ID="$OPTARG"
            ;;
        m)
            COMMENT="$OPTARG"
            ;;
        t)
            USE_TIMESTAMP=true
            ;;
        h)
            usage
            exit 0
            ;;
        :)
            echo "Error: Option -$OPTARG requires an argument."
            usage
            exit 1
            ;;
        \?)
            echo "Error: Unknown option -$OPTARG"
            usage
            exit 1
            ;;
    esac
done

# -b has higher priority than -t
if [ -n "$BUILD_ID" ] && $USE_TIMESTAMP; then
    echo "Warning: both -b and -t specified, using Build ID from -b."
    USE_TIMESTAMP=false
fi

if [ -z "$BUILD_ID" ] && $USE_TIMESTAMP; then
    BUILD_ID="$(date '+%Y%m%d-%H%M%S')"
fi

if [ -n "$BUILD_ID" ]; then
    export IMAGE_BUILD_ID="$BUILD_ID"
fi

if [ -n "$COMMENT" ]; then
    export IMAGE_COMMENT="$COMMENT"
fi

export BB_ENV_PASSTHROUGH_ADDITIONS="${BB_ENV_PASSTHROUGH_ADDITIONS:-} IMAGE_BUILD_ID IMAGE_COMMENT"

echo "========================================"
echo "Building Yocto Image"
echo "========================================"
echo "Image      : $YOCTO_IMAGE"

[ -n "$BUILD_ID" ] && echo "Build ID   : $BUILD_ID"
[ -n "$COMMENT" ] && echo "Comment    : $COMMENT"

echo

bitbake "$YOCTO_IMAGE"

echo
echo "========================================"
echo "Build completed successfully."
echo "========================================"
