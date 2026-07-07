#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config/mender.env"

AUTH_HEADER="Authorization: Bearer $MENDER_PAT"

case "${1:-}" in
    "")
        # Latest deployment
        curl -s \
            -H "$AUTH_HEADER" \
            "$SERVER/api/management/v2/deployments/deployments?page=1&per_page=1" \
        | jq '.[0]'
        ;;

    --all)
        # All deployments
        curl -s \
            -H "$AUTH_HEADER" \
            "$SERVER/api/management/v2/deployments/deployments" \
        | jq
        ;;

    *)
        DEPLOYMENT_ID="$1"

        echo "=== Deployment ==="
        curl -s \
            -H "$AUTH_HEADER" \
            "$SERVER/api/management/v2/deployments/deployments/$DEPLOYMENT_ID" \
        | jq

        echo
        echo "=== Statistics ==="
        curl -s \
            -H "$AUTH_HEADER" \
            "$SERVER/api/management/v2/deployments/deployments/$DEPLOYMENT_ID/statistics" \
        | jq
        ;;
esac

