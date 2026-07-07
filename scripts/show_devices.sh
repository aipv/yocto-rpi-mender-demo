#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config/mender.env"

curl -s \
    -H "Authorization: Bearer $MENDER_PAT" \
    "$SERVER/api/management/v2/devauth/devices" \
| jq
