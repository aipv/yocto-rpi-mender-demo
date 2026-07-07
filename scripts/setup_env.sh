#!/usr/bin/env bash

# This script is intended to be sourced:
#   source scripts/setup-build.sh build-rpi

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Please source this script instead of executing it:"
    echo "  source scripts/setup-build.sh build"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${1:-build}"

cd "${PROJECT_DIR}" || return 1

echo "Initializing submodules..."
git submodule update --init --recursive || return 1

export TEMPLATECONF="${PROJECT_DIR}/meta-rpi-demo/conf/templates/default"
export PATH="${PROJECT_DIR}/scripts:$PATH"

if [ -f "${PROJECT_DIR}/${BUILD_DIR}/conf/local.conf" ]; then
    echo "Using existing build configuration: ${BUILD_DIR}"
else
    echo "Creating new build configuration from TEMPLATECONF: ${TEMPLATECONF}"
fi

source "${PROJECT_DIR}/poky/oe-init-build-env" "${BUILD_DIR}" || return 1

echo
echo "Build environment is ready."
echo

echo "Layers:"
bitbake-layers show-layers || return 1

echo
echo "To build:"
echo "  bitbake rpi-demo-base-image"
