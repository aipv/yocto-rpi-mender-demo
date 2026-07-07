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

FILES=("$DEPLOY_DIR"/*.mender)

if [ ! -e "${FILES[0]}" ]; then
    echo "No .mender artifacts found."
    exit 0
fi

echo "The following artifacts will be removed:"
echo

for file in "${FILES[@]}"; do
    echo "  $(basename "$file")"
done

echo
read -rp "Continue? [y/N] " ANSWER

if [[ ! "$ANSWER" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

rm -f "$DEPLOY_DIR"/*.mender

echo
echo "All .mender artifacts have been removed."
