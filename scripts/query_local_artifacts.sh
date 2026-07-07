#!/bin/bash

set -euo pipefail

if [ $# -eq 0 ]; then
    SEARCH_DIR="."
else
    SEARCH_DIR="$1"
fi

find "$SEARCH_DIR" -type f -name "*.mender" \
    -printf "%TY-%Tm-%Td %TH:%TM  %10s bytes  %p\n" \
    | sort

